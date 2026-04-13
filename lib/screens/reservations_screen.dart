import 'dart:ui';
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

class _AdminReservationsScreenState extends State<AdminReservationsScreen> {
  final ApiService apiService = ApiService();

  // COULEURS DU THÈME
  final Color primaryTurquoise = const Color(0xFF26A69A);
  final Color darkBg = const Color(0xFF0F172A);
  final Color accentRed = const Color(0xFFFF5252);

  List<Reservation> reservations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadReservations();
  }

  Future<void> loadReservations() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final data = await apiService.getAllReservations();
      if (mounted) {
        setState(() {
          reservations = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Erreur de synchronisation avec le serveur")),
        );
      }
    }
  }

  Future<void> cancelReservation(int id) async {
    try {
      await apiService.annulerReservation(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Réservation supprimée")),
        );
        loadReservations();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Échec de la suppression")),
        );
      }
    }
  }

  void confirmCancel(int id, String salleNom) {
    showDialog(
      context: context,
      builder: (_) => BackdropFilter(
        // Floute l'arrière-plan quand le dialogue s'ouvre
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          title: const Text("Annulation",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text(
              "Voulez-vous vraiment annuler la réservation pour la $salleNom ?",
              style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child:
                    const Text("RETOUR", style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentRed,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(context);
                cancelReservation(id);
              },
              child: const Text("CONFIRMER",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildReservationCard(Reservation r, int index) {
    String formattedDate = "Date inconnue";
    if (r.dateReservation != null) {
      try {
        DateTime dt = DateTime.parse(r.dateReservation!);
        formattedDate = DateFormat('EEEE dd MMMM yyyy', 'fr_FR').format(dt);
      } catch (e) {
        formattedDate = r.dateReservation!;
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Icône à gauche avec cercle Turquoise
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryTurquoise.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.bookmark_added_rounded,
                      color: primaryTurquoise, size: 28),
                ),
                const SizedBox(width: 15),

                // Infos centrales
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.salleNom ?? "Salle ${r.salleId}",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        r.utilisateurEmail,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.5), fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              size: 14, color: primaryTurquoise),
                          const SizedBox(width: 6),
                          Text(
                            formattedDate,
                            style: TextStyle(
                                color: primaryTurquoise,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Bouton supprimer à droite
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded,
                      color: accentRed.withOpacity(0.8), size: 26),
                  onPressed: () => confirmCancel(r.id, r.salleNom ?? "Salle"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Réservations",
            style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
                color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Effets de lumière en arrière-plan
          Positioned(
              top: -100,
              right: -50,
              child: _buildBlurCircle(250, primaryTurquoise.withOpacity(0.07))),
          Positioned(
              bottom: -50,
              left: -50,
              child: _buildBlurCircle(200, Colors.blue.withOpacity(0.05))),

          SafeArea(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(color: primaryTurquoise))
                : reservations.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: loadReservations,
                        color: primaryTurquoise,
                        backgroundColor: const Color(0xFF1E293B),
                        child: ListView.builder(
                          itemCount: reservations.length,
                          padding: const EdgeInsets.only(top: 10, bottom: 20),
                          itemBuilder: (context, index) =>
                              buildReservationCard(reservations[index], index),
                        ),
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
          Icon(Icons.event_busy_rounded,
              size: 100, color: Colors.white.withOpacity(0.05)),
          const SizedBox(height: 20),
          const Text("Aucune réservation",
              style: TextStyle(
                  color: Colors.white24,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBlurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}
