import 'dart:convert';

class Salle {
  int id;
  String nom;
  int capacite;
  String image;
  String description;
  bool reservee;

  Salle(
    this.id,
    this.nom,
    this.capacite,
    this.image,
    this.description, {
    this.reservee = false,
  });

  /// 🔹 JSON → Objet
  static Salle fromJson(Map<String, dynamic> json) {
    return Salle(
      json['id'],
      json['nom'],
      json['capacite'],
      json['image'] ?? '',
      json['description'] ?? '',
      reservee: json['reservee'] ?? false,
    );
  }

  /// 🔹 Objet → JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'capacite': capacite,
      'image': image,
      'description': description,
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
