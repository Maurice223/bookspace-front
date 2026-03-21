class Reservation {
  final int id;
  final int salleId;
  final String salleNom;
  final String salleImage;
  final String utilisateurEmail;
  final String? dateReservation; // nullable

  Reservation({
    required this.id,
    required this.salleId,
    required this.salleNom,
    required this.salleImage,
    required this.utilisateurEmail,
    this.dateReservation,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    final salle = json['salle'] ?? {};

    return Reservation(
      id: json['id'] ?? 0, // 0 si null
      salleId: salle['id'] ?? 0, // 0 si null
      salleNom: salle['nom'] ?? '',
      salleImage: salle['image'] ?? 'default.jpg',
      utilisateurEmail: json['utilisateurEmail'] ?? '',
      dateReservation: json['dateReservation'], // peut être null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'salle': {
        'id': salleId,
        'nom': salleNom,
        'image': salleImage,
      },
      'utilisateurEmail': utilisateurEmail,
      'dateReservation': dateReservation,
    };
  }
}
