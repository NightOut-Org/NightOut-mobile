class Setting {
  Setting({
    this.id = 1,
    required this.lang,
    required this.env,
  });

  final int id;
  final String lang;
  final String env;

  factory Setting.fromJson(Map<String, dynamic> json) {
    return Setting(
      id: json['id'] as int? ?? 1,
      lang: json['lang'] as String? ?? '',
      env: json['env'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lang': lang,
      'env': env,
    };
  }
}
