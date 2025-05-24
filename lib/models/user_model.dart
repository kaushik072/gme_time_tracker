class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String degree;
  final String position;
  final String? institution;
  final String? specialty;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.degree,
    required this.position,
    this.institution,
    this.specialty,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String id) {
    return UserModel(
      id: id,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      degree: json['degree']?.toLowerCase() as String,
      position: json['position']?.toLowerCase() as String,
      institution: json['institution']?.toLowerCase() as String?,
      specialty: json['specialty']?.toLowerCase() as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'degree': degree,
      'position': position,
      'institution': institution,
      'specialty': specialty,
    };
  }

  UserModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? degree,
    String? position,
    String? institution,
    String? specialty,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      degree: degree ?? this.degree,
      position: position ?? this.position,
      institution: institution ?? this.institution,
      specialty: specialty ?? this.specialty,
    );
  }
}
