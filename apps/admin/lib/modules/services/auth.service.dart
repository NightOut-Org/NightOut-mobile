import 'dart:convert';
import 'dart:developer';

import 'package:nightout_core/nightout_core.dart';
import 'package:nightoutadmin/models/auth/auth.models.dart';
import 'package:nightoutadmin/utils/http.dart';

class AuthService {
  AuthService({Http? http, Http? authHttp, String? baseUrl, String? supabaseUrl, String? anonKey})
    : _http = http ?? Http(baseUrl: baseUrl),
      _authHttp = authHttp ?? Http(baseUrl: supabaseUrl ?? Env.supabaseUrl),
      _baseUrl = _trim(baseUrl ?? Env.apiBaseUrl),
      _supabaseUrl = _trim(supabaseUrl ?? Env.supabaseUrl),
      _anonKey = anonKey ?? Env.supabaseAnonKey;

  final Http _http;
  final Http _authHttp;
  final String _baseUrl;
  final String _supabaseUrl;
  final String _anonKey;

  static String _trim(String value) {
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }

  Future<AuthSession> signInWithPassword({required String email, required String password}) async {
    final json = await _send(
      method: 'POST',
      path: '/auth/v1/token',
      query: const {'grant_type': 'password'},
      headers: _anonHeaders(required: true),
      body: {'email': email, 'password': password},
    );
    log('signInWithPassword: ${json.toString()}');
    final session = AuthSession.fromJson(json);
    if (session.accessToken.isEmpty) {
      throw const AuthException(message: 'ไม่ได้รับโทเคนจากระบบ');
    }
    return session;
  }

  Future<AdminProfile> fetchProfile(String accessToken) async {
    final json = await _send(method: 'GET', path: '/me/profile', headers: _userHeaders(accessToken));
    log('fetchProfile: ${json.toString()}');
    return AdminProfile.fromJson(_dataMap(json));
  }

  Future<AuthUser> fetchUser(String accessToken) async {
    final json = await _send(method: 'GET', path: '/auth/v1/user', headers: _userHeaders(accessToken));
    log('fetchUser: ${json.toString()}');

    return AuthUser.fromJson(json);
  }

  Future<void> unenrollTotp({required String accessToken, required String factorId}) async {
    await _send(
      method: 'DELETE',
      path: '/auth/v1/factors/${Uri.encodeComponent(factorId)}',
      headers: _userHeaders(accessToken),
    );
  }

  Future<TotpEnrollment> enrollTotp(
    String accessToken, {
    String factorType = 'totp',
    String friendlyName = 'NightOut Admin',
    String issuer = 'NightOut Admin',
  }) async {
    final json = await _send(
      method: 'POST',
      path: '/auth/v1/factors',
      headers: _userHeaders(accessToken),
      body: {
        'factor_type': factorType,
        'friendly_name': friendlyName,
        'issuer': issuer,
      },
    );
    log('enrollTotp: ${json.toString()}');
    final enrollment = TotpEnrollment.fromJson(json);
    if (enrollment.factorId.isEmpty || enrollment.secret.isEmpty) {
      throw const AuthException(message: 'ผูก Authenticator ไม่สำเร็จ');
    }
    return enrollment;
  }

  Future<String> challengeTotp({required String accessToken, required String factorId}) async {
    final json = await _send(
      method: 'POST',
      path: '/auth/v1/factors/${Uri.encodeComponent(factorId)}/challenge',
      headers: _userHeaders(accessToken),
      body: const {},
    );
    log('challengeTotp: ${json.toString()}');
    final id = json['id'] as String? ?? '';
    if (id.isEmpty) {
      throw const AuthException(message: 'สร้างรหัสท้าทายไม่สำเร็จ');
    }
    return id;
  }

  Future<AuthSession> verifyTotp({
    required String accessToken,
    required String factorId,
    required String challengeId,
    required String code,
  }) async {
    final json = await _send(
      method: 'POST',
      path: '/auth/v1/factors/${Uri.encodeComponent(factorId)}/verify',
      headers: _userHeaders(accessToken),
      body: {'challenge_id': challengeId, 'code': code},
    );
    log('verifyTotp: ${json.toString()}');
    final session = AuthSession.fromJson(json);
    if (session.accessToken.isEmpty) {
      throw const AuthException(message: 'ยืนยันรหัสไม่สำเร็จ');
    }
    return session;
  }

  Future<AdminDashboard> fetchDashboard(String accessToken) async {
    final json = await _send(method: 'GET', path: '/api/admin/dashboard', headers: _userHeaders(accessToken));
    return AdminDashboard.fromData(json['data']);
  }

  Future<void> signOut(String accessToken) {
    return _send(method: 'POST', path: '/auth/v1/logout', headers: _userHeaders(accessToken), body: const {});
  }

  Map<String, String> _anonHeaders({required bool required}) {
    if (required && _anonKey.isEmpty) {
      throw const AuthException(message: 'ยังไม่ได้ตั้งค่า SUPABASE_ANON_KEY');
    }
    return {'apikey': _anonKey, 'Authorization': 'Bearer $_anonKey', 'Content-Type': 'application/json'};
  }

  Map<String, String> _userHeaders(String accessToken) {
    return {
      if (_anonKey.isNotEmpty) 'apikey': _anonKey,
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
  }

  Future<Map<String, dynamic>> _send({
    required String method,
    required String path,
    required Map<String, String> headers,
    Map<String, String>? query,
    Map<String, dynamic>? body,
  }) async {
    final isAuth = path.startsWith('/auth/');
    if (isAuth && _supabaseUrl.isEmpty) {
      throw const AuthException(message: 'ยังไม่ได้ตั้งค่า SUPABASE_URL');
    }
    if (!isAuth && _baseUrl.isEmpty) {
      throw const AuthException(message: 'ยังไม่ได้ตั้งค่า API_BASE_URL');
    }
    final response = await (isAuth ? _authHttp : _http).send(
      method: method,
      path: path,
      query: query,
      headers: headers,
      body: body,
    );
    final text = response.body;
    if (response.statusCode >= 400) throw _errorFrom(response.statusCode, text);
    if (text.isEmpty) return const {};
    final decoded = jsonDecode(text);
    if (decoded is! Map) {
      throw const AuthException(message: 'คำตอบจากระบบไม่ถูกต้อง');
    }
    final json = Map<String, dynamic>.from(decoded);
    final errorCode = json['error_code'];
    if (errorCode is String && errorCode.isNotEmpty) {
      throw AuthException(statusCode: response.statusCode, errorCode: errorCode, message: _messageOf(json));
    }
    if (!isAuth) {
      final status = json['status'];
      if (status is String && status.isNotEmpty && status != 'ok') {
        throw AuthException(
          statusCode: (json['status_code'] as num?)?.toInt() ?? response.statusCode,
          errorCode: json['code']?.toString(),
          message: _messageOf(json),
        );
      }
    }
    return json;
  }

  Map<String, dynamic> _dataMap(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map) return Map<String, dynamic>.from(data);
    return json;
  }

  AuthException _errorFrom(int statusCode, String body) {
    Map<String, dynamic>? json;
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) json = Map<String, dynamic>.from(decoded);
    } on FormatException {
      json = null;
    }
    return AuthException(
      statusCode: statusCode,
      errorCode: json?['error_code']?.toString() ?? json?['code']?.toString(),
      message: json == null ? 'คำขอไม่สำเร็จ' : _messageOf(json),
    );
  }

  String _messageOf(Map<String, dynamic> json) {
    final message = json['msg'] ?? json['message'] ?? json['err_msg'];
    if (message is String && message.isNotEmpty) return message;
    return 'คำขอไม่สำเร็จ';
  }
}
