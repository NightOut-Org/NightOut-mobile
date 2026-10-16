// Apps reach Supabase (auth only, root AGENTS.md) through these types, so they
// never depend on supabase_flutter directly.
export 'package:supabase_flutter/supabase_flutter.dart'
    show
        AuthChangeEvent,
        AuthException,
        AuthMFAChallengeResponse,
        AuthMFAEnrollResponse,
        AuthMFAGetAuthenticatorAssuranceLevelResponse,
        AuthMFAListFactorsResponse,
        AuthMFAUnenrollResponse,
        AuthMFAVerifyResponse,
        AuthResponse,
        AuthState,
        AuthenticatorAssuranceLevels,
        Factor,
        FactorStatus,
        FactorType,
        GoTrueClient,
        GoTrueMFAApi,
        Session,
        TOTPEnrollment,
        User;

export 'src/api/api_client.dart';
export 'src/api/api_exception.dart';
export 'src/api/my_profile.dart';
export 'src/auth/supabase.dart';
export 'src/env.dart';
export 'src/motion.dart';
export 'src/theme/auth_colors.dart';
export 'src/theme/theme.dart';
export 'src/theme/theme_mode.dart';
export 'src/theme/tokens.dart';
export 'src/widgets/gradient_title.dart';
export 'src/widgets/load_widget.dart';
export 'src/widgets/theme_mode_menu.dart';
