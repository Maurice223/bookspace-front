class Utilisateur {
  final int id;
  final String nom;
  final String prenom;
  final String nomUtilisateur; // ← Nouveau champ
  final String email;
  final String? telephone; // ← Nouveau champ (Optionnel avec ?)
  final String role;
  String? photo;

  Utilisateur({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.nomUtilisateur, // ← Requis
    required this.email,
    this.telephone, // ← Optionnel
    required this.role,
    this.photo,
  });

  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    return Utilisateur(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? "",
      prenom: json['prenom'] ?? "",
      nomUtilisateur: json['nomUtilisateur'] ?? "", // ← Mapping JSON
      email: json['email'] ?? "",
      telephone: json['telephone'], // ← Mapping JSON
      role: json['role'] ?? "USER",
      photo: json['photo'],
    );
  }

  // Optionnel : Ajouter une méthode toJson si tu dois envoyer ces données au serveur
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'nomUtilisateur': nomUtilisateur,
      'email': email,
      'telephone': telephone,
      'role': role,
      'photo': photo,
    };
  }
}
