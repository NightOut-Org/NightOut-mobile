class AppInfo {
  const AppInfo({
    this.appName = '',
    this.packageName = '',
    this.os = '',
    this.osVersion = '',
    this.appVersion = '',
    this.buildNumber = '',
    this.deviceId = '',
    this.model = '',
    this.dpi = '',
    this.resolution = '',
  });

  final String appName;
  final String packageName;
  final String os;
  final String osVersion;
  final String appVersion;
  final String buildNumber;
  final String deviceId;
  final String model;
  final String dpi;
  final String resolution;

  AppInfo copyWith({
    String? appName,
    String? packageName,
    String? os,
    String? osVersion,
    String? appVersion,
    String? buildNumber,
    String? deviceId,
    String? model,
    String? dpi,
    String? resolution,
  }) {
    return AppInfo(
      appName: appName ?? this.appName,
      packageName: packageName ?? this.packageName,
      os: os ?? this.os,
      osVersion: osVersion ?? this.osVersion,
      appVersion: appVersion ?? this.appVersion,
      buildNumber: buildNumber ?? this.buildNumber,
      deviceId: deviceId ?? this.deviceId,
      model: model ?? this.model,
      dpi: dpi ?? this.dpi,
      resolution: resolution ?? this.resolution,
    );
  }

  factory AppInfo.fromJson(Map<String, dynamic> json) {
    return AppInfo(
      appName: json['app_name'] as String? ?? '',
      packageName: json['package_name'] as String? ?? '',
      os: json['os'] as String? ?? '',
      osVersion: json['os_version'] as String? ?? '',
      appVersion: json['app_version'] as String? ?? '',
      buildNumber: json['build_number'] as String? ?? '',
      deviceId: json['device_id'] as String? ?? '',
      model: json['model'] as String? ?? '',
      dpi: json['dpi'] as String? ?? '',
      resolution: json['resolution'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'app_name': appName,
      'package_name': packageName,
      'os': os,
      'os_version': osVersion,
      'app_version': appVersion,
      'build_number': buildNumber,
      'device_id': deviceId,
      'model': model,
      'dpi': dpi,
      'resolution': resolution,
    };
  }
}
