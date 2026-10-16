class LogData {
  LogData({
    required this.id,
    required this.message,
    required this.createdAt,
    required this.passcode,
  });

  final int id;
  final String message;
  final String createdAt;
  final bool passcode;

  factory LogData.fromJson(Map<String, dynamic> json) {
    return LogData(
      id: json['id'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      passcode: json['passcode'] == true || json['passcode'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'created_at': createdAt,
      'passcode': passcode ? 1 : 0,
    };
  }
}
