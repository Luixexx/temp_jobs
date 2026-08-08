class ContractParty {
  final String id;
  final String nombre;
  final String email;

  ContractParty({required this.id, required this.nombre, required this.email});

  factory ContractParty.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ContractParty(id: '', nombre: '', email: '');
    return ContractParty(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class ContractComment {
  final ContractParty by;
  final String body;
  final String? createdAt;

  ContractComment({required this.by, required this.body, this.createdAt});

  factory ContractComment.fromJson(Map<String, dynamic> json) {
    return ContractComment(
      by: ContractParty.fromJson(json['by']),
      body: json['body'] ?? '',
      createdAt: json['createdAt'],
    );
  }
}

class ContractPhoto {
  final ContractParty by;
  final String url;
  final String description;
  final String? createdAt;

  ContractPhoto({
    required this.by,
    required this.url,
    required this.description,
    this.createdAt,
  });

  factory ContractPhoto.fromJson(Map<String, dynamic> json) {
    return ContractPhoto(
      by: ContractParty.fromJson(json['by']),
      url: json['url'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['createdAt'],
    );
  }
}

class Contract {
  final String id;
  final String offerId;
  final String jobTypeName;
  final ContractParty contratante;
  final ContractParty contratado;
  final String myRole; // contratante | contratado
  final num? salary;
  final String? currency;
  final String? startDate;
  final String? duration;
  final String status; // pending, active, rejected, cancelled
  final String? cancelJustification;
  final List<ContractComment> comments;
  final List<ContractPhoto> photos;

  Contract({
    required this.id,
    required this.offerId,
    required this.jobTypeName,
    required this.contratante,
    required this.contratado,
    required this.myRole,
    this.salary,
    this.currency,
    this.startDate,
    this.duration,
    required this.status,
    this.cancelJustification,
    required this.comments,
    required this.photos,
  });

  bool get isContratante => myRole == 'contratante';
  bool get hasTerms => salary != null && startDate != null && duration != null;

  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      id: json['id']?.toString() ?? '',
      offerId: json['offerId']?.toString() ?? '',
      jobTypeName: json['jobTypeName'] ?? '',
      contratante: ContractParty.fromJson(json['contratante']),
      contratado: ContractParty.fromJson(json['contratado']),
      myRole: json['myRole'] ?? '',
      salary: json['salary'],
      currency: json['currency'],
      startDate: json['startDate'],
      duration: json['duration'],
      status: json['status'] ?? 'pending',
      cancelJustification: json['cancelJustification'],
      comments: (json['comments'] as List? ?? [])
          .map((e) => ContractComment.fromJson(e))
          .toList(),
      photos: (json['photos'] as List? ?? [])
          .map((e) => ContractPhoto.fromJson(e))
          .toList(),
    );
  }
}
