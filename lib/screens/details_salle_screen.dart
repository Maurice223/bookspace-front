// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../models/salle.dart';
import '../services/api_service.dart';

class DetailsSalleScreen extends StatefulWidget {
  final Salle salle;
  final String utilisateurEmail;

  const DetailsSalleScreen({
    super.key,
    required this.salle,
    required this.utilisateurEmail,
  });

  @override
  State<DetailsSalleScreen> createState() => _DetailsSalleScreenState();
}

class _DetailsSalleScreenState extends State<DetailsSalleScreen> {
  final ApiService apiService = ApiService();

  bool isLoading = false;
  bool isFavorite = false;

  void reserverSalle() async {
    setState(() => isLoading = true);

    // 🔹 On réserve pour aujourd'hui
    bool success = await apiService.reserverSalleAvecDate(
        widget.salle.id, widget.utilisateurEmail, DateTime.now());

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: success ? Colors.green : Colors.red,
        content: Text(success
            ? "Réservation confirmée 🎉"
            : "Erreur lors de la réservation"),
      ),
    );

    if (success) {
      // 🔹 On marque la salle comme réservée localement
      setState(() {
        widget.salle.reservee = true;
      });

      // 🔹 Retour à l'écran précédent avec mise à jour
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = widget.salle.image.isNotEmpty
        ? "assets/images/${widget.salle.image}"
        : "assets/images/default.jpg";

    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),

      /// 🔥 BOUTON BAS PREMIUM
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(15),
        child: ElevatedButton(
          onPressed: widget.salle.reservee || isLoading ? null : reserverSalle,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 10,
          ),
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  widget.salle.reservee
                      ? "Salle déjà réservée"
                      : "Réserver maintenant",
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
        ),
      ),

      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.salle.nom,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                        blurRadius: 10,
                        color: Colors.black,
                        offset: Offset(0, 2)),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                      tag: widget.salle.id,
                      child: Image.asset(imagePath, fit: BoxFit.cover)),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.8)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                      key: ValueKey<bool>(isFavorite)),
                ),
                onPressed: () {
                  setState(() {
                    isFavorite = !isFavorite;
                  });
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// BADGE DISPONIBILITÉ
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.salle.reservee
                          ? Colors.red.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.salle.reservee ? "🔴 Occupée" : "🟢 Disponible",
                      style: TextStyle(
                        color:
                            widget.salle.reservee ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    children: [
                      _infoCard(
                          Icons.people, "${widget.salle.capacite}", "Places"),
                      const SizedBox(width: 15),
                      _infoCard(Icons.meeting_room, "Salle", "Type"),
                    ],
                  ),

                  const SizedBox(height: 25),

                  const Text("Description",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 10)
                      ],
                    ),
                    child: Text(
                      widget.salle.description.isNotEmpty
                          ? widget.salle.description
                          : "Pas de description disponible",
                      style: const TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xff6a11cb), Color(0xff2575fc)]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 10),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
