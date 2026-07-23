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
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
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
    );
  }
}
