class Utilisateur {
  final int id;
  final String nom;
  final String prenom;
  String? photo;
  final String email;
  final String role;

  Utilisateur({
    required this.id,
    required this.nom,
    required this.prenom,
    this.photo,
    required this.email,
    required this.role,
  });

  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    return Utilisateur(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? "",
      prenom: json['prenom'] ?? "", // ← IMPORTANT
      photo: json['photo'],
      email: json['email'] ?? "",
      role: json['role'] ?? "USER",
    );
  }
}
