import 'package:json_annotation/json_annotation.dart';

part 'my_profile.g.dart';

/// `GET /me/profile` (web `MyProfile` in `packages/contracts/src/account.ts`).
@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class MyProfile {
  const MyProfile({
    required this.id,
    required this.displayName,
    required this.role,
    required this.roleLabel,
    required this.canEnterBackoffice,
    required this.phoneE164,
    required this.bannedAt,
    required this.banReason,
    required this.avatarUrl,
  });

  factory MyProfile.fromJson(Map<String, dynamic> json) => _$MyProfileFromJson(json);

  final String id;
  final String displayName;

  /// Web `UserRole` (`CUSTOMER`, `MERCHANT`, `STAFF`, `ADMIN`, `SUPER_ADMIN`).
  /// A string, not an enum, so a role added on the server cannot break sign-in;
  /// gate on [canEnterBackoffice] and show [roleLabel].
  final String role;
  final String roleLabel;
  final bool canEnterBackoffice;
  final String? phoneE164;
  final DateTime? bannedAt;
  final String? banReason;
  final String? avatarUrl;
}
