import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nightout_core/nightout_core.dart';

/// Every `/admin/*` 401 means "verify the 6-digit code again" (web `Rest.configure`).
const mfaRequiredCode = 'MFA_REQUIRED';

final apiClientProvider = Provider<ApiClient>((ref) {
  final auth = ref.watch(supabaseAuthProvider);
  return ApiClient(
    baseUrl: Env.apiBaseUrl,
    unauthorizedCode: mfaRequiredCode,
    // getSession refreshes an expired token; currentSession may still hold one right after launch.
    accessToken: () async => (await auth.getSession())?.accessToken,
  );
});
