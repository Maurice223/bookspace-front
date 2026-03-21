import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/reservation.dart';
import 'package:intl/intl.dart';

class AdminReservationsScreen extends StatefulWidget {
  const AdminReservationsScreen({super.key});

  @override
  State<AdminReservationsScreen> createState() =>
      _AdminReservationsScreenState();
}

class _AdminReservationsScreenState extends State<AdminReservationsScreen>
    with SingleTickerProviderStateMixin {
  List<Reservation> reservations = [];
  bool isLoading = true;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    loadReservations();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _controller.forward();
  }

  Future<void> loadReservations() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService().fetchReservations();
      setState(() {
        reservations = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur chargement réservations: $e")),
      );
    }
  }

  Future<void> cancelReservation(int id) async {
    try {
      await ApiService().annulerReservation(id);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Réservation annulée")));
      loadReservations();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erreur: $e")));
    }
  }

  void confirmCancel(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Confirmation"),
        content: const Text("Annuler cette réservation ?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Non")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              cancelReservation(id);
            },
            child: const Text(
              "Oui",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildReservationCard(Reservation r, int index) {
    final formattedDate = r.dateReservation != null
        ? DateFormat('dd/MM/yyyy').format(DateTime.parse(r.dateReservation!))
        : "Non précisée";

    return AnimatedOpacity(
      opacity: 1.0,
      duration: Duration(milliseconds: 300 + index * 100),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 6)),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(8),

          // IMAGE DE LA SALLE
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              "assets/images/${r.salleImage}",
              width: 55,
              height: 55,
              fit: BoxFit.cover,
            ),
          ),

          // INFOS
          title: Text(
            r.salleNom,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.white70),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      r.utilisateurEmail,
                      style: const TextStyle(color: Colors.white70),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 16, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(
                    formattedDate,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),

          // ACTIONS
          trailing: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => confirmCancel(r.id),
            icon: const Icon(Icons.cancel, size: 18, color: Colors.white),
            label: const Text("Annuler", style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Réservations",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : reservations.isEmpty
                ? const Center(
                    child: Text(
                      "Aucune réservation",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                : ListView.builder(
                    itemCount: reservations.length,
                    itemBuilder: (context, index) =>
                        buildReservationCard(reservations[index], index),
                  ),
      ),
    );
  }
}
