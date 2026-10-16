class DropdownOption {
  const DropdownOption({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  factory DropdownOption.fromJson(Map<String, dynamic> json) {
    return DropdownOption(
      value: json['value']?.toString() ?? '',
      label: json['label']?.toString() ?? json['name']?.toString() ?? '',
    );
  }
}
