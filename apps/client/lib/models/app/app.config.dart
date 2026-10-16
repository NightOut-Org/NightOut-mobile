class AppConfig {
  const AppConfig({
    this.name = '',
    this.baseUrl = '',
    this.version = '',
    this.iosStore = '',
    this.androidStore = '',
    this.notice = '',
    this.screenshot = true,
    this.sslSha256 = const [],
  });

  final String name;
  final String baseUrl;
  final String version;
  final String iosStore;
  final String androidStore;
  final String notice;
  final bool screenshot;
  final List<String> sslSha256;

  AppConfig copyWith({
    String? name,
    String? baseUrl,
    String? version,
    String? iosStore,
    String? androidStore,
    String? notice,
    bool? screenshot,
    List<String>? sslSha256,
  }) {
    return AppConfig(
      name: name ?? this.name,
      baseUrl: baseUrl ?? this.baseUrl,
      version: version ?? this.version,
      iosStore: iosStore ?? this.iosStore,
      androidStore: androidStore ?? this.androidStore,
      notice: notice ?? this.notice,
      screenshot: screenshot ?? this.screenshot,
      sslSha256: sslSha256 ?? this.sslSha256,
    );
  }

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    final raw = json['ssl_sha256'];
    return AppConfig(
      name: json['name'] as String? ?? '',
      baseUrl: json['base_url'] as String? ?? '',
      version: json['version'] as String? ?? '',
      iosStore: json['ios_store'] as String? ?? '',
      androidStore: json['android_store'] as String? ?? '',
      notice: json['notice'] as String? ?? '',
      screenshot: json['screenshot'] is bool ? json['screenshot'] as bool : true,
      sslSha256: raw is List ? raw.map((e) => e.toString()).toList() : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'base_url': baseUrl,
      'version': version,
      'ios_store': iosStore,
      'android_store': androidStore,
      'notice': notice,
      'screenshot': screenshot,
      'ssl_sha256': sslSha256,
    };
  }
}
