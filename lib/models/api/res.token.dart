class ResToken {
  ResToken({
    required this.token,
    required this.pk,
    required this.status,
    required this.errorCode,
    required this.errorDesc,
    required this.data,
  });
  late String token = "";
  late String pk = "";
  late String status = "";
  late String errorCode = "";
  late String errorDesc = "";
  late dynamic data;

  ResToken.create() {
    token = "";
    pk = "";
    status = "N";
    errorCode = "999";
    errorDesc = "Exception";
  }

  ResToken.fromJson(Map<String, dynamic> json) {
    token = json['token'] ?? "";
    pk = json['pk'] ?? "";
    status = json['status'] ?? "";
    errorCode = json['error_code'] ?? "";
    errorDesc = json['error_desc'] ?? "";
    data = json['data'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json['token'] = token;
    json['pk'] = pk;
    json['status'] = status;
    json['error_code'] = errorCode;
    json['error_desc'] = errorDesc;
    json['data'] = data;
    return json;
  }
}
