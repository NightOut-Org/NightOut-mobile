import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../env.dart';

/// Call once in `main` after `WidgetsFlutterBinding.ensureInitialized()`.
/// Use only `auth` from Supabase; data goes through `ApiClient` (root AGENTS.md).
Future<void> initNightOutSupabase() async {
  await Supabase.initialize(url: Env.supabaseUrl, publishableKey: Env.supabaseAnonKey);
}

/// Override in tests with a fake [GoTrueClient].
final supabaseAuthProvider = Provider<GoTrueClient>(
  (ref) => Supabase.instance.client.auth,
);
