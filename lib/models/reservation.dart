class Reservation {
  final int id;
  final int salleId;
  final String salleNom;
  final String salleImage;
  final String utilisateurEmail;
  final String? dateReservation;
  final String? creneauHoraire; // ✅ Ajout du champ pour les blocs de 3h

  Reservation({
    required this.id,
    required this.salleId,
    required this.salleNom,
    required this.salleImage,
    required this.utilisateurEmail,
    this.dateReservation,
    this.creneauHoraire, // ✅ Ajout au constructeur
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    // On récupère l'objet salle imbriqué envoyé par Spring Boot
    final salle = json['salle'] ?? {};

    return Reservation(
      id: json['id'] ?? 0,
      salleId: salle['id'] ?? 0,
      salleNom: salle['nom'] ?? 'Salle inconnue',
      salleImage: salle['image'] ?? 'default.jpg',
      utilisateurEmail: json['utilisateurEmail'] ?? '',
      dateReservation: json['dateReservation'],
      creneauHoraire:
          json['creneauHoraire'], // ✅ Lecture du créneau (ex: "08:00 - 11:00")
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
      'creneauHoraire': creneauHoraire, // ✅ Exportation vers le JSON
    };
  }
}
