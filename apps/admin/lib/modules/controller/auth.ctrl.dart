import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nightout_core/nightout_core.dart';
import 'package:nightout_core/supabase_auth.dart' show AuthException;
import 'package:nightoutadmin/providers/api.provider.dart';

/// Where the Backoffice login stands (web `apps/admin/src/modules/login/page.tsx`).
sealed class AdminAuth {
  const AdminAuth();
}

/// Password step.
final class AdminSignedOut extends AdminAuth {
  const AdminSignedOut({this.error});

  final String? error;
}

/// Code step: enroll when [enrollment] is set, verify otherwise.
final class AdminNeedsCode extends AdminAuth {
  const AdminNeedsCode({required this.email, required this.factorId, this.enrollment, this.error});

  final String email;
  final String factorId;
  final TOTPEnrollment? enrollment;
  final String? error;

  AdminNeedsCode withError(String? error) =>
      AdminNeedsCode(email: email, factorId: factorId, enrollment: enrollment, error: error);
}

final class AdminSignedIn extends AdminAuth {
  const AdminSignedIn({required this.profile, required this.email});

  final MyProfile profile;
  final String email;
}

const _issuer = 'NightOut Admin';

class AuthController extends Notifier<AdminAuth> {
  @override
  AdminAuth build() {
    final subscription = ref.watch(supabaseAuthProvider).onAuthStateChange.listen(
      (change) {
        // Catches sign-outs we did not start (refresh token revoked). Ours already set AdminSignedOut,
        // maybe with an error that this late event must not erase.
        if (change.event == AuthChangeEvent.signedOut && state is! AdminSignedOut) {
          state = const AdminSignedOut();
        }
      },
      // Offline token refreshes arrive here; the next API call surfaces them.
      onError: (Object _) {},
    );
    ref.onDispose(subscription.cancel);
    return const AdminSignedOut();
  }

  GoTrueClient get _auth => ref.read(supabaseAuthProvider);

  /// App launch: continue whatever session Supabase restored from storage.
  Future<void> restore() => _guard(() async {
    // Not currentSession: Supabase.initialize does not wait for session recovery, so a stored token can
    // still be expired here; getSession refreshes it first.
    final session = await _auth.getSession();
    if (session == null) {
      state = const AdminSignedOut();
      return;
    }
    // Keep the session if /me/profile fails: an offline launch should not cost a full password + code login.
    await _continue(session.user.email ?? '', signOutIfUnreadable: false);
  });

  Future<void> signIn(String email, String password) async {
    final address = email.trim();
    if (address.isEmpty || password.isEmpty) {
      state = const AdminSignedOut(error: 'กรอกอีเมลและรหัสผ่าน');
      return;
    }
    await _guard(() async {
      state = const AdminSignedOut();
      await _auth.signInWithPassword(email: address, password: password);
      await _continue(address, signOutIfUnreadable: true);
    });
  }

  Future<void> verify(String code) async {
    final step = state;
    if (step is! AdminNeedsCode || code.length != 6) return;
    await _guard(() async {
      state = step.withError(null);
      await _auth.mfa.challengeAndVerify(factorId: step.factorId, code: code);
      await _continue(step.email, signOutIfUnreadable: false);
    });
  }

  /// An `/admin/*` call answered `MFA_REQUIRED`: ask for the code again rather than signing out.
  Future<void> requireMfa() async {
    final session = _auth.currentSession;
    if (session == null) {
      state = const AdminSignedOut();
      return;
    }
    final current = state;
    if (current is AdminNeedsCode) return;
    final email = current is AdminSignedIn ? current.email : session.user.email ?? '';
    await _guard(() => _startMfa(email));
  }

  /// Both "ใช้บัญชีอื่น" on the code step and "ออกจากระบบ" on the account tab.
  Future<void> signOut() async {
    await _signOut();
    state = const AdminSignedOut();
  }

  void clearError() {
    if (state case AdminSignedOut(error: _?)) state = const AdminSignedOut();
  }

  Future<void> _continue(String email, {required bool signOutIfUnreadable}) async {
    final MyProfile profile;
    try {
      profile = await ref
          .read(apiClientProvider)
          .get('/me/profile', (data) => MyProfile.fromJson(data! as Map<String, dynamic>));
    } on ApiException catch (e) {
      if (signOutIfUnreadable) await _signOut();
      state = AdminSignedOut(
        error:
            'ล็อกอินผ่านแล้ว แต่อ่านข้อมูลบัญชีจากเซิร์ฟเวอร์ไม่ได้ (${e.statusCode} · ${e.code}) — ไม่ใช่เรื่องสิทธิ์ ให้ตรวจ API / Supabase',
      );
      return;
    }
    if (!profile.canEnterBackoffice) {
      await _signOut();
      state = AdminSignedOut(error: 'บัญชีนี้เป็นชั้น "${profile.roleLabel}" ซึ่งเข้า Backoffice ไม่ได้');
      return;
    }
    if (_auth.mfa.getAuthenticatorAssuranceLevel().currentLevel == AuthenticatorAssuranceLevels.aal2) {
      state = AdminSignedIn(profile: profile, email: email);
      return;
    }
    await _startMfa(email);
  }

  Future<void> _startMfa(String email) async {
    final factors = await _auth.mfa.listFactors();
    final verified = factors.totp.firstOrNull;
    if (verified != null) {
      state = AdminNeedsCode(email: email, factorId: verified.id);
      return;
    }
    // A factor scanned but never verified makes the next enroll fail on the same friendly name.
    final stale = factors.all.where((f) => f.factorType == FactorType.totp && f.status == FactorStatus.unverified);
    for (final factor in stale) {
      await _auth.mfa.unenroll(factor.id);
    }
    final enrolled = await _auth.mfa.enroll(factorType: FactorType.totp, issuer: _issuer, friendlyName: _issuer);
    state = AdminNeedsCode(email: email, factorId: enrolled.id, enrollment: enrolled.totp);
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
    } on AuthException {
      // gotrue drops the local session before calling the server; only the remote revoke failed.
    }
  }

  /// One flow at a time (web `mfaStarted`): a double tap must not start a second sign-in or enroll.
  /// Errors land on the step the user is on and never sign out.
  Future<void> _guard(Future<void> Function() flow) async {
    if (ref.read(authBusy)) return;
    final busy = ref.read(authBusy.notifier).._set(true);
    try {
      await flow();
    } on Exception catch (e) {
      final message = switch (e) {
        AuthException() => _authMessage(e),
        ApiException() => e.message,
        _ => '$e',
      };
      state = switch (state) {
        final AdminNeedsCode step => step.withError(message),
        _ => AdminSignedOut(error: message),
      };
    } finally {
      busy._set(false);
    }
  }
}

class AuthBusy extends Notifier<bool> {
  @override
  bool build() => false;

  void _set(bool value) => state = value;
}

final authCtrl = NotifierProvider<AuthController, AdminAuth>(AuthController.new);

/// True while a login flow runs; only [AuthController] changes it.
final authBusy = NotifierProvider<AuthBusy, bool>(AuthBusy.new);

const _codeMessage = 'รหัส 6 หลักไม่ถูกต้องหรือหมดเวลาแล้ว ใช้รหัสล่าสุดจากแอปแล้วลองอีกครั้ง';
const _rateLimitMessage = 'ลองหลายครั้งเกินไป รอสักครู่แล้วลองใหม่';

String _authMessage(AuthException e) => switch (e.code) {
  'invalid_credentials' => 'อีเมลหรือรหัสผ่านไม่ถูกต้อง',
  'email_not_confirmed' => 'บัญชีนี้ยังไม่ได้ยืนยันอีเมล',
  'mfa_verification_failed' || 'mfa_challenge_expired' => _codeMessage,
  'over_request_rate_limit' || 'over_email_send_rate_limit' => _rateLimitMessage,
  _ => _toThai(e.message),
};

/// Web `toThai`, for errors that come without a code.
String _toThai(String message) {
  bool has(String pattern) => RegExp(pattern, caseSensitive: false).hasMatch(message);
  if (has('invalid login credentials')) return 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';
  if (has('email not confirmed')) return 'บัญชีนี้ยังไม่ได้ยืนยันอีเมล';
  if (has('invalid totp|code|expired')) return _codeMessage;
  if (has('rate limit|too many')) return _rateLimitMessage;
  return message;
}
