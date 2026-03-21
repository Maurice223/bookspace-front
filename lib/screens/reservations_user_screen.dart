import 'package:flutter/material.dart';
import '../models/reservation.dart';
import '../services/api_service.dart';

class MesReservationsPage extends StatefulWidget {
  final String email;

  const MesReservationsPage({super.key, required this.email});

  @override
  State<MesReservationsPage> createState() => _MesReservationsPageState();
}

class _MesReservationsPageState extends State<MesReservationsPage> {
  final ApiService apiService = ApiService();

  late Future<List<Reservation>> futureReservations;

  @override
  void initState() {
    super.initState();

    futureReservations = apiService.getReservationsUtilisateur(widget.email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Réservations"),
      ),
      body: FutureBuilder<List<Reservation>>(
        future: futureReservations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          }

          final reservations = snapshot.data!;

          if (reservations.isEmpty) {
            return const Center(
              child: Text("Aucune réservation"),
            );
          }

          return ListView.builder(
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final reservation = reservations[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: const Icon(
                    Icons.meeting_room,
                    color: Colors.blue,
                  ),
                  title: Text(reservation.salleNom),
                  subtitle: Text(reservation.utilisateurEmail),
                  trailing: const Icon(Icons.check_circle, color: Colors.green),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
