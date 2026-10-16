import 'dart:convert';

class AuthException implements Exception {
  const AuthException({
    this.statusCode,
    this.errorCode,
    required this.message,
  });

  final int? statusCode;
  final String? errorCode;
  final String message;

  bool get isInvalidCredentials => errorCode == 'invalid_credentials';

  bool get isMfaFailed =>
      errorCode == 'mfa_verification_failed' || statusCode == 400;

  @override
  String toString() => message;
}

class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.tokenType,
    this.userId,
    this.email,
  });

  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final String tokenType;
  final String? userId;
  final String? email;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final userMap = user is Map ? Map<String, dynamic>.from(user) : null;
    return AuthSession(
      accessToken: json['access_token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
      expiresIn: (json['expires_in'] as num?)?.toInt() ?? 0,
      tokenType: json['token_type'] as String? ?? 'bearer',
      userId: userMap?['id'] as String? ?? json['user_id'] as String?,
      email: userMap?['email'] as String? ?? json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_in': expiresIn,
      'token_type': tokenType,
      'user_id': userId,
      'email': email,
    };
  }

  static AuthSession? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final session = AuthSession.fromJson(Map<String, dynamic>.from(decoded));
      if (session.accessToken.isEmpty) return null;
      return session;
    } on FormatException {
      return null;
    }
  }
}

class AdminProfile {
  const AdminProfile({
    required this.id,
    required this.displayName,
    required this.role,
    required this.roleLabel,
    required this.canEnterBackoffice,
    this.phoneE164,
    this.bannedAt,
    this.banReason,
  });

  final String id;
  final String displayName;
  final String role;
  final String roleLabel;
  final bool canEnterBackoffice;
  final String? phoneE164;
  final String? bannedAt;
  final String? banReason;

  factory AdminProfile.fromJson(Map<String, dynamic> json) {
    return AdminProfile(
      id: json['id'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      role: json['role'] as String? ?? '',
      roleLabel: json['role_label'] as String? ?? '',
      canEnterBackoffice: json['can_enter_backoffice'] == true,
      phoneE164: json['phone_e164'] as String?,
      bannedAt: json['banned_at'] as String?,
      banReason: json['ban_reason'] as String?,
    );
  }
}

class AuthFactor {
  const AuthFactor({
    required this.id,
    required this.factorType,
    required this.status,
  });

  final String id;
  final String factorType;
  final String status;

  bool get isVerifiedTotp => factorType == 'totp' && status == 'verified';

  factory AuthFactor.fromJson(Map<String, dynamic> json) {
    return AuthFactor(
      id: json['id'] as String? ?? '',
      factorType: (json['factor_type'] ?? json['type']) as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }
}

class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.factors,
  });

  final String id;
  final String email;
  final List<AuthFactor> factors;

  AuthFactor? get verifiedTotp {
    for (final factor in factors) {
      if (factor.isVerifiedTotp && factor.id.isNotEmpty) return factor;
    }
    return null;
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final raw = json['factors'];
    final factors = raw is List
        ? raw
            .whereType<Map>()
            .map((item) => AuthFactor.fromJson(Map<String, dynamic>.from(item)))
            .toList()
        : const <AuthFactor>[];
    return AuthUser(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      factors: factors,
    );
  }
}

class TotpEnrollment {
  const TotpEnrollment({
    required this.factorId,
    required this.secret,
    required this.uri,
    required this.qrCode,
  });

  final String factorId;
  final String secret;
  final String uri;
  final String qrCode;

  factory TotpEnrollment.fromJson(Map<String, dynamic> json) {
    final totp = json['totp'];
    final totpMap = totp is Map ? Map<String, dynamic>.from(totp) : const <String, dynamic>{};
    return TotpEnrollment(
      factorId: json['id'] as String? ?? '',
      secret: totpMap['secret'] as String? ?? '',
      uri: totpMap['uri'] as String? ?? '',
      qrCode: totpMap['qr_code'] as String? ?? '',
    );
  }
}

class DashboardItem {
  const DashboardItem({required this.label, required this.count});

  final String label;
  final int count;

  factory DashboardItem.fromJson(Map<String, dynamic> json) {
    final count = json['count'] ?? json['value'] ?? json['total'];
    return DashboardItem(
      label: (json['label'] ?? json['title'] ?? json['name'] ?? '').toString(),
      count: count is num ? count.toInt() : int.tryParse('$count') ?? 0,
    );
  }
}

class AdminDashboard {
  const AdminDashboard({
    required this.total,
    required this.unit,
    required this.items,
  });

  final int total;
  final String unit;
  final List<DashboardItem> items;

  factory AdminDashboard.fromData(dynamic data) {
    if (data is! Map) {
      return const AdminDashboard(total: 0, unit: 'รายการ', items: []);
    }
    final json = Map<String, dynamic>.from(data);
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems
            .whereType<Map>()
            .map((item) => DashboardItem.fromJson(Map<String, dynamic>.from(item)))
            .where((item) => item.label.isNotEmpty)
            .toList()
        : const <DashboardItem>[];
    final totalValue = json['total'] ?? json['headline'];
    final total = totalValue is num
        ? totalValue.toInt()
        : items.fold<int>(0, (sum, item) => sum + item.count);
    return AdminDashboard(
      total: total,
      unit: json['unit'] as String? ?? 'รายการ',
      items: items,
    );
  }
}

String groupSecret(String secret) {
  final clean = secret.replaceAll(' ', '');
  final buffer = StringBuffer();
  for (var i = 0; i < clean.length; i++) {
    if (i > 0 && i % 4 == 0) buffer.write(' ');
    buffer.write(clean[i]);
  }
  return buffer.toString();
}
