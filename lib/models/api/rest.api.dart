class RestApi {
  RestApi({
    required this.status,
    required this.errorCode,
    required this.errorDesc,
    required this.errorDescInternal,
    required this.data,
  });
  late final String status;
  late final String errorCode;
  late final String errorDesc;
  late final String errorDescInternal;
  late final dynamic data;

  RestApi.fromJson(Map<String, dynamic> json) {
    status = json['status'] ?? "";
    errorCode = json['error_code'] ?? "";
    errorDesc = json['error_desc'] ?? "";
    errorDescInternal = json['error_desc_internal'] ?? "";
    data = json['data'];
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json['status'] = status;
    json['error_code'] = errorCode;
    json['error_desc'] = errorDesc;
    json['error_desc_internal'] = errorDescInternal;
    json['data'] = data;
    return json;
  }

  @override
  String toString() {
    return "{ status: $status, error_code: $errorCode, error_desc: $errorDesc, error_desc_internal: $errorDescInternal, data: $data }";
  }
}
