class Application {
  final String id;
  final String offerId;
  final String comment;
  final int? rating;
  final String status; // applied, discarded, finalist, winner
  final String? appliedAt;
  // Solo presente cuando el dueño ve la lista de aplicantes:
  final String? applicantName;
  final String? applicantEmail;
  // Solo presente en "mis aplicaciones", para saber a qué oferta corresponde:
  final String? offerJobTypeName;

  Application({
    required this.id,
    required this.offerId,
    required this.comment,
    this.rating,
    required this.status,
    this.appliedAt,
    this.applicantName,
    this.applicantEmail,
    this.offerJobTypeName,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    // El dueño ve la identidad del aplicante, a veces anidada
    final applicant = json['applicant'] ?? json['user'];
    // "mis aplicaciones" puede traer la oferta anidada
    final offer = json['offer'];

    return Application(
      id: json['id']?.toString() ?? '',
      offerId: json['offerId']?.toString() ?? offer?['id']?.toString() ?? '',
      comment: json['comment'] ?? '',
      rating: json['rating'],
      status: json['status'] ?? 'applied',
      appliedAt: json['appliedAt'] ?? json['createdAt'],
      applicantName: applicant != null
          ? '${applicant['firstName'] ?? ''} ${applicant['lastName'] ?? ''}'
                .trim()
          : null,
      applicantEmail: applicant?['email'],
      offerJobTypeName: offer?['jobTypeName'] ?? offer?['jobTypeKey'],
    );
  }
}
