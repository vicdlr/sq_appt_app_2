class ServiceOptionModel {
  final String key;
  final String value;

  ServiceOptionModel({
    required this.key,
    required this.value,
  });

  factory ServiceOptionModel.fromJson(Map<String, dynamic> json) {
    return ServiceOptionModel(
      key: json['key'] ?? '',
      value: json['value'] ?? '',
    );
  }
}
