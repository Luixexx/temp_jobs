class CustomField {
  final String key;
  final String label;
  final String type; // text, number, date, select, check
  final bool required;
  final List<String> options;

  CustomField({
    required this.key,
    required this.label,
    required this.type,
    required this.required,
    required this.options,
  });

  factory CustomField.fromJson(Map<String, dynamic> json) {
    return CustomField(
      key: json['key'] ?? '',
      label: json['label'] ?? '',
      type: json['type'] ?? 'text',
      required: json['required'] ?? false,
      options:
          (json['options'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class JobType {
  final String id;
  final String key;
  final String name;
  final bool active;
  final List<CustomField> customFields;

  JobType({
    required this.id,
    required this.key,
    required this.name,
    required this.active,
    required this.customFields,
  });

  factory JobType.fromJson(Map<String, dynamic> json) {
    return JobType(
      id: json['id'] ?? '',
      key: json['key'] ?? '',
      name: json['name'] ?? json['key'] ?? '',
      active: json['active'] ?? true,
      customFields: (json['customFields'] as List? ?? [])
          .map((e) => CustomField.fromJson(e))
          .toList(),
    );
  }
}
