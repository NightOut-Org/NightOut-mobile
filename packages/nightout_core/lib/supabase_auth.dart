// Kept out of nightout_core.dart while apps/admin declares its own
// AuthException and AuthState; importing both there would be ambiguous.
export 'package:supabase_flutter/supabase_flutter.dart' show AuthException, AuthState;
