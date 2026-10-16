import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nightout/modules/api/api.provider.dart';
import 'package:nightout_core/nightout_core.dart';

sealed class CustomerAuth {
  const CustomerAuth();
}

/// Until the splash has called [CustomerAuthController.restore].
final class CustomerRestoring extends CustomerAuth {
  const CustomerRestoring();
}

final class CustomerSignedOut extends CustomerAuth {
  const CustomerSignedOut({this.error});

  final String? error;
}

final class CustomerSignedIn extends CustomerAuth {
  const CustomerSignedIn({required this.profile, required this.email});

  final MyProfile profile;
  final String email;
}

class CustomerAuthController extends Notifier<CustomerAuth> {
  /// Web `authLoginForm.tsx` shows this for every failed sign-in.
  static const invalidCredentials = 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';

  GoTrueClient get _auth => ref.read(supabaseAuthProvider);

  @override
  CustomerAuth build() {
    final auth = ref.watch(supabaseAuthProvider);
    final subscription = auth.onAuthStateChange.listen(
      (change) {
        // The stream replays earlier events to new listeners, so check that the
        // session is really gone. Covers a refresh token that stopped working.
        if (change.event == AuthChangeEvent.signedOut && auth.currentSession == null && state is! CustomerSignedOut) {
          state = const CustomerSignedOut();
        }
      },
      // Refresh failures arrive here too; a lost session also sends signedOut.
      onError: (Object _) {},
    );
    ref.onDispose(subscription.cancel);
    return const CustomerRestoring();
  }

  Future<void> restore() async {
    final session = _auth.currentSession;
    if (session == null) {
      _set(const CustomerSignedOut());
      return;
    }
    // Keep the stored session when the profile fails here (offline launch, as
    // the web does), so the next launch can try again.
    await _loadProfile(session.user.email, signOutOnFailure: false);
  }

  Future<void> signIn(String email, String password) async {
    _set(const CustomerSignedOut());
    final AuthResponse response;
    try {
      response = await _auth.signInWithPassword(email: email, password: password);
    } on AuthException {
      _set(const CustomerSignedOut(error: invalidCredentials));
      return;
    }
    await _loadProfile(response.user?.email ?? email, signOutOnFailure: true);
  }

  Future<void> signOut() async {
    await _endSession();
    _set(const CustomerSignedOut());
  }

  /// gotrue clears the local session first, then rethrows a failed server
  /// call. The device is signed out either way.
  Future<void> _endSession() async {
    try {
      await _auth.signOut();
    } on AuthException {
      // Only the server-side revoke failed.
    }
  }

  Future<void> _loadProfile(String? email, {required bool signOutOnFailure}) async {
    final String? error;
    try {
      final profile = await ref
          .read(apiClientProvider)
          .get('/me/profile', (data) => MyProfile.fromJson(data! as Map<String, dynamic>));
      _set(CustomerSignedIn(profile: profile, email: email ?? ''));
      return;
    } on ApiException catch (e) {
      error = e.message;
    } on AuthException {
      // The token refresh in getSession() failed; the login page is enough.
      error = null;
    }
    if (signOutOnFailure) await _endSession();
    _set(CustomerSignedOut(error: error));
  }

  void _set(CustomerAuth next) {
    if (ref.mounted) state = next;
  }
}

final customerAuthProvider = NotifierProvider<CustomerAuthController, CustomerAuth>(
  CustomerAuthController.new,
);
