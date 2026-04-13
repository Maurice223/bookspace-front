import 'dart:convert';

class Salle {
  int id;
  String nom;
  int capacite;
  String image;
  String description;
  String type; // ✅ "TP" ou "COURS"
  bool reservee;

  Salle(
    this.id,
    this.nom,
    this.capacite,
    this.image,
    this.description, {
    this.type =
        "COURS", // ✅ Par défaut, on considère que c'est une salle de cours
    this.reservee = false,
  });

  /// 🔹 JSON → Objet (Désérialisation)
  static Salle fromJson(Map<String, dynamic> json) {
    return Salle(
      json['id'],
      json['nom'],
      json['capacite'],
      json['image'] ?? '',
      json['description'] ?? '',
      type: json['type'] ?? 'COURS', // ✅ Récupère le type du JSON
      reservee: json['reservee'] ?? false,
    );
  }

  /// 🔹 Objet → JSON (Sérialisation)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'capacite': capacite,
      'image': image,
      'description': description,
      'type': type, // ✅ Ajouté au JSON
      'reservee': reservee,
    };
  }

  /// 🔹 Liste JSON → Liste objets
  static List<Salle> fromJsonList(String str) {
    return List<Salle>.from(
      json.decode(str).map((x) => Salle.fromJson(x)),
    );
  }
}
