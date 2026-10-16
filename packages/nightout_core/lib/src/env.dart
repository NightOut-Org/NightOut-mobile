/// Values come from `--dart-define-from-file=.env.dev` at build time.
abstract final class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const authRedirectUrl = String.fromEnvironment('AUTH_REDIRECT_URL');
}
