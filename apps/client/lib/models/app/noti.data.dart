class NotiData {
  const NotiData({
    this.title = '',
    this.body = '',
    this.type = '',
    this.payload = const {},
  });

  final String title;
  final String body;
  final String type;
  final Map<String, dynamic> payload;

  factory NotiData.fromJson(Map<String, dynamic> json) {
    return NotiData(
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      type: json['type'] as String? ?? '',
      payload: json['payload'] is Map<String, dynamic>
          ? json['payload'] as Map<String, dynamic>
          : {},
    );
  }
}
