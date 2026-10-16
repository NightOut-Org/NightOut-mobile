import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nightout_core/nightout_core.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final auth = ref.watch(supabaseAuthProvider);
  return ApiClient(
    baseUrl: Env.apiBaseUrl,
    // getSession() refreshes an expired token; currentSession does not, and the
    // session restored at launch is often older than the token's lifetime.
    accessToken: () async => (await auth.getSession())?.accessToken,
  );
});
