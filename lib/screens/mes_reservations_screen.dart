import 'package:flutter/material.dart';
import '../models/reservation.dart';
import '../models/salle.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class MesReservationsScreen extends StatefulWidget {
  final String email;

  const MesReservationsScreen({super.key, required this.email});

  @override
  State<MesReservationsScreen> createState() => _MesReservationsScreenState();
}

class _MesReservationsScreenState extends State<MesReservationsScreen> {
  final ApiService apiService = ApiService();

  List<Reservation> reservations = [];
  Map<int, Salle> salles = {};

  bool loading = true;

  @override
  void initState() {
    super.initState();
    chargerReservations();
  }

  Future<void> chargerReservations() async {
    try {
      reservations = await apiService.getReservationsUtilisateur(widget.email);

      for (var r in reservations) {
        if (!salles.containsKey(r.salleId)) {
          Salle salle = await apiService.getSalleById(r.salleId);
          salles[r.salleId] = salle;
        }
      }

      setState(() {
        loading = false;
      });
    } catch (e) {
      print("Erreur chargement reservations $e");
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> annuler(int id) async {
    await apiService.annulerReservation(id);

    // Recharge la liste
    await chargerReservations();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Réservation annulée"),
      ),
    );
  }

  String formatDate(String date) {
    if (date.isEmpty) return "Date inconnue";
    try {
      final dt = DateTime.parse(date);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: AppBar(
        title: const Text(
          "Mes Réservations",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigo,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : reservations.isEmpty
              ? const Center(
                  child: Text(
                    "Aucune réservation",
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: reservations.length,
                  itemBuilder: (context, index) {
                    Reservation r = reservations[index];
                    Salle salle = salles[r.salleId]!;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          // DATE en haut
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.indigo,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: Text(
                              formatDate(r.dateReservation ?? ''),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          Row(
                            children: [
                              // IMAGE
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                ),
                                child: Image.asset(
                                  "assets/images/${salle.image}",
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),

                              const SizedBox(width: 12),

                              // INFOS + BOUTON
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        salle.nom,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "Capacité : ${salle.capacite}",
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 12),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: ElevatedButton.icon(
                                          onPressed: () => annuler(r.id),
                                          icon: const Icon(Icons.delete,
                                              color: Colors.white),
                                          label: const Text(
                                            "Annuler",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.redAccent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 20),
                                            elevation: 5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
