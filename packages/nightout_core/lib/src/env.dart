/// Values come only from `--dart-define-from-file=../../.env.dev` (run from the app folder).
/// No defaults: URLs and keys stay out of the code (root AGENTS.md).
abstract final class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const authRedirectUrl = String.fromEnvironment('AUTH_REDIRECT_URL');
}
