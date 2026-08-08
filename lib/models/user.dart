class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String nombre;
  final String referralMatricula;
  final String role;
  final String? createdAt;
  final String? lastLoginAt;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.nombre,
    required this.referralMatricula,
    required this.role,
    this.createdAt,
    this.lastLoginAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      nombre: json['nombre'] ?? '',
      referralMatricula: json['referralMatricula'] ?? '',
      role: json['role'] ?? '',
      createdAt: json['createdAt'],
      lastLoginAt: json['lastLoginAt'],
    );
  }
}
