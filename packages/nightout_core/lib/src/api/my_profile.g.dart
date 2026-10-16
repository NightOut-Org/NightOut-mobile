// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyProfile _$MyProfileFromJson(Map<String, dynamic> json) => MyProfile(
  id: json['id'] as String,
  displayName: json['display_name'] as String,
  role: json['role'] as String,
  roleLabel: json['role_label'] as String,
  canEnterBackoffice: json['can_enter_backoffice'] as bool,
  phoneE164: json['phone_e164'] as String?,
  bannedAt: json['banned_at'] == null
      ? null
      : DateTime.parse(json['banned_at'] as String),
  banReason: json['ban_reason'] as String?,
  avatarUrl: json['avatar_url'] as String?,
);
