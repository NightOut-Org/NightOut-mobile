/// Dev defaults live here. `--dart-define-from-file=.env.dev` overrides them at build time.
abstract final class Env {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://pxueavqyykdipcjqbxyd.supabase.co',
  );
  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_KM8XHP6cWXv-M4C-B2imdg_RMoj52vL',
  );
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://night-out-demo.vercel.app/api',
  );
  static const authRedirectUrl = String.fromEnvironment(
    'AUTH_REDIRECT_URL',
    defaultValue: 'nightout://auth-callback',
  );
}
