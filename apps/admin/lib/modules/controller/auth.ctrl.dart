import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nightoutadmin/config.dart';
import 'package:nightoutadmin/models/auth/auth.models.dart';
import 'package:nightoutadmin/modules/services/auth.service.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LoginPhase { credentials, enroll, verify }

class AuthState {
  const AuthState({
    this.phase = LoginPhase.credentials,
    this.session,
    this.pendingAccessToken,
    this.factorId,
    this.enrollment,
    this.profile,
    this.dashboard,
    this.email,
    this.credentialsInvalid = false,
    this.codeInvalid = false,
    this.notice,
    this.busy = false,
  });

  final LoginPhase phase;
  final AuthSession? session;
  final String? pendingAccessToken;
  final String? factorId;
  final TotpEnrollment? enrollment;
  final AdminProfile? profile;
  final AdminDashboard? dashboard;
  final String? email;
  final bool credentialsInvalid;
  final bool codeInvalid;
  final String? notice;
  final bool busy;

  bool get isSignedIn => session != null;

  AuthState copyWith({
    LoginPhase? phase,
    AuthSession? session,
    bool clearSession = false,
    String? pendingAccessToken,
    bool clearPending = false,
    String? factorId,
    bool clearFactor = false,
    TotpEnrollment? enrollment,
    bool clearEnrollment = false,
    AdminProfile? profile,
    bool clearProfile = false,
    AdminDashboard? dashboard,
    bool clearDashboard = false,
    String? email,
    bool? credentialsInvalid,
    bool? codeInvalid,
    String? notice,
    bool clearNotice = false,
    bool? busy,
  }) {
    return AuthState(
      phase: phase ?? this.phase,
      session: clearSession ? null : session ?? this.session,
      pendingAccessToken: clearPending ? null : pendingAccessToken ?? this.pendingAccessToken,
      factorId: clearFactor ? null : factorId ?? this.factorId,
      enrollment: clearEnrollment ? null : enrollment ?? this.enrollment,
      profile: clearProfile ? null : profile ?? this.profile,
      dashboard: clearDashboard ? null : dashboard ?? this.dashboard,
      email: email ?? this.email,
      credentialsInvalid: credentialsInvalid ?? this.credentialsInvalid,
      codeInvalid: codeInvalid ?? this.codeInvalid,
      notice: clearNotice ? null : notice ?? this.notice,
      busy: busy ?? this.busy,
    );
  }
}

class _BackofficeBundle {
  const _BackofficeBundle({
    required this.user,
    required this.profile,
    required this.dashboard,
  });

  final AuthUser user;
  final AdminProfile profile;
  final AdminDashboard dashboard;
}

final authService = Provider<AuthService>((ref) => AuthService());

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  AuthService get _service => ref.read(authService);

  Future<bool> restore() async {
    final prefs = await SharedPreferences.getInstance();
    if (!ref.mounted) return false;
    final session = AuthSession.tryParse(prefs.getString(Config.sessionStorageKey));
    if (session == null) {
      state = const AuthState();
      return false;
    }
    try {
      final bundle = await _loadBackoffice(session.accessToken);
      if (!ref.mounted) return false;
      if (!bundle.profile.canEnterBackoffice) {
        await _dropSession(prefs, session.accessToken);
        if (!ref.mounted) return false;
        state = const AuthState(notice: 'บัญชีนี้เข้า Backoffice ไม่ได้');
        return false;
      }
      state = AuthState(
        session: session,
        profile: bundle.profile,
        dashboard: bundle.dashboard,
        email: bundle.user.email.isEmpty ? session.email : bundle.user.email,
      );
      return true;
    } on AuthException {
      await _dropSession(prefs, session.accessToken);
      if (!ref.mounted) return false;
      state = const AuthState();
      return false;
    }
  }

  Future<void> submitPassword({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || password.isEmpty) {
      state = state.copyWith(
        phase: LoginPhase.credentials,
        credentialsInvalid: false,
        notice: 'กรอกอีเมลและรหัสผ่าน',
        clearSession: true,
      );
      return;
    }

    state = state.copyWith(
      busy: true,
      credentialsInvalid: false,
      clearNotice: true,
      phase: LoginPhase.credentials,
    );
    AuthSession? granted;
    try {
      granted = await _service.signInWithPassword(email: trimmedEmail, password: password);
      final session = granted;
      final profile = await _service.fetchProfile(session.accessToken);
      if (!profile.canEnterBackoffice) {
        await _remoteSignOut(session.accessToken);
        if (!ref.mounted) return;
        state = const AuthState(notice: 'บัญชีนี้เข้า Backoffice ไม่ได้');
        return;
      }
      final user = await _service.fetchUser(session.accessToken);
      if (!ref.mounted) return;
      final verified = user.verifiedTotp;
      if (verified != null) {
        state = AuthState(
          phase: LoginPhase.verify,
          pendingAccessToken: session.accessToken,
          factorId: verified.id,
          email: user.email.isEmpty ? session.email : user.email,
          profile: profile,
        );
        return;
      }
      final enrollment = await _service.enrollTotp(session.accessToken);
      if (!ref.mounted) return;
      state = AuthState(
        phase: LoginPhase.enroll,
        pendingAccessToken: session.accessToken,
        factorId: enrollment.factorId,
        enrollment: enrollment,
        email: user.email.isEmpty ? session.email : user.email,
        profile: profile,
      );
    } on AuthException catch (error) {
      if (granted != null) await _remoteSignOut(granted.accessToken);
      if (!ref.mounted) return;
      state = AuthState(
        credentialsInvalid: error.isInvalidCredentials,
        notice: error.isInvalidCredentials ? null : error.message,
      );
    } finally {
      if (ref.mounted) state = state.copyWith(busy: false);
    }
  }

  Future<void> submitCode(String code) async {
    final token = state.pendingAccessToken;
    final factorId = state.factorId;
    if (token == null || factorId == null || code.length != 6) return;

    state = state.copyWith(busy: true, clearNotice: true);
    try {
      final challengeId = await _service.challengeTotp(accessToken: token, factorId: factorId);
      final session = await _service.verifyTotp(
        accessToken: token,
        factorId: factorId,
        challengeId: challengeId,
        code: code,
      );
      await _persist(session);
      if (!ref.mounted) return;
      state = state.copyWith(
        session: session,
        clearPending: true,
        phase: LoginPhase.verify,
        codeInvalid: false,
        email: session.email ?? state.email,
      );
      try {
        final bundle = await _loadBackoffice(session.accessToken);
        if (!ref.mounted) return;
        state = state.copyWith(
          profile: bundle.profile,
          dashboard: bundle.dashboard,
          email: bundle.user.email.isEmpty ? state.email : bundle.user.email,
        );
      } on AuthException catch (error) {
        if (!ref.mounted) return;
        state = state.copyWith(notice: error.message);
      }
    } on AuthException catch (error) {
      if (!ref.mounted) return;
      state = state.copyWith(
        phase: LoginPhase.verify,
        codeInvalid: error.isMfaFailed,
        notice: error.isMfaFailed ? null : error.message,
      );
    } finally {
      if (ref.mounted) state = state.copyWith(busy: false);
    }
  }

  Future<void> reloadBackoffice() async {
    final token = state.session?.accessToken;
    if (token == null) return;
    state = state.copyWith(busy: true, clearNotice: true);
    try {
      final bundle = await _loadBackoffice(token);
      if (!ref.mounted) return;
      state = state.copyWith(
        profile: bundle.profile,
        dashboard: bundle.dashboard,
        email: bundle.user.email.isEmpty ? state.email : bundle.user.email,
      );
    } on AuthException catch (error) {
      if (!ref.mounted) return;
      state = state.copyWith(notice: error.message);
    } finally {
      if (ref.mounted) state = state.copyWith(busy: false);
    }
  }

  Future<void> skipEnroll() {
    return signOut(notice: 'ต้องผูก Authenticator ก่อนเข้า Backoffice');
  }

  void resetCode() {
    state = state.copyWith(codeInvalid: false, clearNotice: true);
  }

  void clearCredentialError() {
    if (state.phase != LoginPhase.credentials) return;
    if (!state.credentialsInvalid && state.notice == null) return;
    state = state.copyWith(credentialsInvalid: false, clearNotice: true);
  }

  Future<void> signOut({String? notice}) async {
    final token = state.session?.accessToken ?? state.pendingAccessToken;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(Config.sessionStorageKey);
    await _remoteSignOut(token);
    if (!ref.mounted) return;
    state = AuthState(notice: notice);
  }

  Future<_BackofficeBundle> _loadBackoffice(String accessToken) async {
    final user = await _service.fetchUser(accessToken);
    final profile = await _service.fetchProfile(accessToken);
    final dashboard = await _service.fetchDashboard(accessToken);
    return _BackofficeBundle(user: user, profile: profile, dashboard: dashboard);
  }

  Future<void> _persist(AuthSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(Config.sessionStorageKey, jsonEncode(session.toJson()));
  }

  Future<void> _dropSession(SharedPreferences prefs, String? token) async {
    await prefs.remove(Config.sessionStorageKey);
    await _remoteSignOut(token);
  }

  Future<void> _remoteSignOut(String? token) async {
    if (token == null || token.isEmpty) return;
    try {
      await _service.signOut(token);
    } on AuthException {
      // เซสชันในเครื่องถูกล้างแล้ว แม้เซิร์ฟเวอร์จะปฏิเสธการออกจากระบบ
    }
  }
}

final authCtrl = NotifierProvider<AuthController, AuthState>(AuthController.new);
