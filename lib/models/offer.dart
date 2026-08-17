class OfferQuestion {
  final String id;
  final String label;
  final String type; // text, date, select, check
  final bool required;
  final List<String> options;

  OfferQuestion({
    required this.id,
    required this.label,
    required this.type,
    required this.required,
    required this.options,
  });

  factory OfferQuestion.fromJson(Map<String, dynamic> json) {
    return OfferQuestion(
      id: json['id']?.toString() ?? '',
      label: json['label'] ?? '',
      type: json['type'] ?? 'text',
      required: json['required'] ?? false,
      options: (json['options'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

class Offer {
  final String id;
  final String jobTypeKey;
  final String jobTypeName;
  final String contractType;
  final String description;
  final String address;
  final String photo;
  final int likesCount;
  final String? deadline;
  final String? createdAt;
  final double? latitude;
  final double? longitude;
  final List<OfferQuestion> questions;

  Offer({
    required this.id,
    required this.jobTypeKey,
    required this.jobTypeName,
    required this.contractType,
    required this.description,
    required this.address,
    required this.photo,
    required this.likesCount,
    this.deadline,
    this.createdAt,
    this.latitude,
    this.longitude,
    required this.questions,
  });

  bool get hasLocation => latitude != null && longitude != null;

  factory Offer.fromJson(Map<String, dynamic> json) {
    final location = json['location'];
    return Offer(
      id: json['id']?.toString() ?? '',
      jobTypeKey: json['jobTypeKey'] ?? '',
      jobTypeName: json['jobTypeName'] ?? json['jobTypeKey'] ?? '',
      contractType: json['contractType'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      photo: json['photo'] ?? '',
      likesCount: json['likesCount'] ?? 0,
      deadline: json['deadline'],
      createdAt: json['createdAt'],
      latitude: (location?['lat'] as num?)?.toDouble(),
      longitude: (location?['lng'] as num?)?.toDouble(),
      questions: (json['questions'] as List? ?? [])
          .map((e) => OfferQuestion.fromJson(e))
          .toList(),
    );
  }
}
