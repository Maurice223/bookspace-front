import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/reservation.dart';
import '../models/salle.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class MesReservationsScreen extends StatefulWidget {
  final String utilisateurEmail;

  const MesReservationsScreen({super.key, required this.utilisateurEmail});

  @override
  State<MesReservationsScreen> createState() => _MesReservationsScreenState();
}

class _MesReservationsScreenState extends State<MesReservationsScreen> {
  final ApiService apiService = ApiService();
  final Color primaryTurquoise = const Color(0xFF26A69A);
  final Color darkBg = const Color(0xFF0F172A);

  List<Reservation> reservations = [];
  Map<int, Salle> salles = {}; // Pour stocker les infos des salles liées
  bool loading = true;

  @override
  void initState() {
    super.initState();
    chargerReservations();
  }

  Future<void> chargerReservations() async {
    if (!mounted) return;
    setState(() => loading = true);
    try {
      final data =
          await apiService.getReservationsUtilisateur(widget.utilisateurEmail);

      // Récupération des détails de chaque salle si pas encore en mémoire
      for (var r in data) {
        if (!salles.containsKey(r.salleId)) {
          try {
            Salle salle = await apiService.getSalleById(r.salleId);
            salles[r.salleId] = salle;
          } catch (e) {
            print("Erreur salle ID ${r.salleId}: $e");
          }
        }
      }

      if (mounted) {
        setState(() {
          reservations = data;
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => loading = false);
      debugPrint("Erreur chargement réservations : $e");
    }
  }

  Future<void> annuler(int id) async {
    bool confirm = await _showConfirmDialog();
    if (!confirm) return;

    setState(() => loading = true);
    try {
      await apiService.annulerReservation(id);
      await chargerReservations(); // Recharger la liste après suppression

      if (mounted) {
        _showSnackBar("Réservation annulée", isError: true);
      }
    } catch (e) {
      if (mounted) setState(() => loading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : primaryTurquoise,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<bool> _showConfirmDialog() async {
    return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: darkBg,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title:
                const Text("Annuler ?", style: TextStyle(color: Colors.white)),
            content: const Text(
                "Voulez-vous vraiment annuler cette réservation ?",
                style: TextStyle(color: Colors.white70)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text("Non")),
              TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text("Oui, annuler",
                      style: TextStyle(color: Colors.redAccent))),
            ],
          ),
        ) ??
        false;
  }

  String formatDate(String? date) {
    if (date == null || date.isEmpty) return "Date inconnue";
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
      backgroundColor: darkBg,
      appBar: AppBar(
        title: const Text("Mes Réservations",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned(
              bottom: -50,
              right: -50,
              child: _buildBlurCircle(200, primaryTurquoise.withOpacity(0.1))),
          loading
              ? Center(
                  child: CircularProgressIndicator(color: primaryTurquoise))
              : reservations.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: chargerReservations,
                      color: primaryTurquoise,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: reservations.length,
                        itemBuilder: (context, index) {
                          Reservation r = reservations[index];
                          Salle? salle = salles[r.salleId];
                          return _buildReservationCard(r, salle);
                        },
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _buildReservationCard(Reservation r, Salle? salle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        color: Colors.white.withOpacity(0.03),
      ),
      child: Column(
        children: [
          // Header de la carte avec la Date et le CRÉNEAU
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            decoration: BoxDecoration(
              color: primaryTurquoise.withOpacity(0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.event_available,
                        color: primaryTurquoise, size: 16),
                    const SizedBox(width: 8),
                    Text(formatDate(r.dateReservation),
                        style: TextStyle(
                            color: primaryTurquoise,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                // ✅ AFFICHAGE DU CRÉNEAU HORAIRE
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryTurquoise,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    r.creneauHoraire ?? "3 Heures",
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                // Image de la salle
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    "assets/images/${salle?.image ?? 'default.jpg'}",
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                        width: 70,
                        height: 70,
                        color: Colors.white10,
                        child: const Icon(Icons.image, color: Colors.white24)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(salle?.nom ?? "Salle chargée...",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text("Capacité: ${salle?.capacite ?? '??'} places",
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 12)),
                    ],
                  ),
                ),
                // Bouton Annuler
                IconButton(
                  onPressed: () => annuler(r.id),
                  icon:
                      const Icon(Icons.delete_outline, color: Colors.redAccent),
                  tooltip: "Annuler",
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined,
              size: 80, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 20),
          const Text("Vous n'avez pas de réservations",
              style: TextStyle(color: Colors.white54, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildBlurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
