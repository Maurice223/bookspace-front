import 'dart:ui';
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

  // Thème de couleurs
  final Color primaryTurquoise = const Color(0xFF26A69A);
  final Color darkBg = const Color(0xFF0F172A);
  final Color occupiedRed = const Color(0xFFEF5350);
  final Color availableGreen = const Color(0xFF66BB6A);

  bool isLoading = false;

  // Gestion de la Réservation
  DateTime selectedDate = DateTime.now();
  String? selectedSlot;
  List<String> takenSlots = [];

  final List<String> availableSlots = [
    "08:00 - 11:00",
    "11:00 - 14:00",
    "14:00 - 17:00",
    "17:00 - 20:00",
  ];

  bool get isTP => widget.salle.type.toUpperCase() == "TP";

  @override
  void initState() {
    super.initState();
    _checkAvailability();
  }

  // 1. RÉCUPÉRATION DES CRÉNEAUX OCCUPÉS
  void _checkAvailability() async {
    setState(() => isLoading = true);
    try {
      List<String> result =
          await apiService.getOccupiedSlots(widget.salle.id, selectedDate);
      setState(() {
        takenSlots = result;
        if (takenSlots.contains(selectedSlot)) selectedSlot = null;
      });
    } catch (e) {
      debugPrint("Erreur disponibilité: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // 2. CONFIRMATION DE LA RÉSERVATION
  void reserverSalle() async {
    if (selectedSlot == null) {
      _showCustomSnackBar("Veuillez choisir un créneau horaire", isError: true);
      return;
    }

    setState(() => isLoading = true);

    bool success = await apiService.reserverSalleAvecDate(
        widget.salle.id, widget.utilisateurEmail, selectedDate, selectedSlot!);

    setState(() => isLoading = false);

    if (success) {
      _showCustomSnackBar("Réservation confirmée pour le $selectedSlot 🎉");
      Future.delayed(
          const Duration(seconds: 1), () => Navigator.pop(context, true));
    } else {
      _showCustomSnackBar("Échec : Ce créneau est déjà occupé.", isError: true);
      _checkAvailability();
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = widget.salle.image.isNotEmpty
        ? "assets/images/${widget.salle.image}"
        : "assets/images/default.jpg";

    return Scaffold(
      backgroundColor: darkBg,
      extendBody: true,
      bottomNavigationBar: _buildBottomAction(),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(imagePath),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderInfo(),
                  const SizedBox(height: 30),
                  _buildCapacityCards(),
                  const SizedBox(height: 35),
                  const Text("Planifier votre réservation",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _buildDateTimePicker(),
                  const SizedBox(height: 35),
                  const Text("Description",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  _buildDescriptionSection(),
                  const SizedBox(height: 150),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- COMPOSANTS DE L'INTERFACE ---

  Widget _buildSliverAppBar(String imagePath) {
    return SliverAppBar(
      expandedHeight: 350,
      pinned: true,
      backgroundColor: darkBg,
      leading: IconButton(
        icon: const CircleAvatar(
          backgroundColor: Colors.black26,
          child: Icon(Icons.arrow_back, color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: "salle_image_${widget.salle.id}",
          child: Image.asset(imagePath, fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: primaryTurquoise.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: primaryTurquoise.withOpacity(0.3)),
          ),
          child: Text(widget.salle.type,
              style: TextStyle(
                  color: primaryTurquoise, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 15),
        Text(widget.salle.nom,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildCapacityCards() {
    return Row(
      children: [
        _infoCard(Icons.people_outline, "${widget.salle.capacite}", "Places"),
        const SizedBox(width: 20),
        _infoCard(
          isTP ? Icons.computer_rounded : Icons.school_rounded,
          isTP ? "TP" : "COURS",
          "Catégorie",
          iconColor: isTP ? Colors.purpleAccent : primaryTurquoise,
        ),
      ],
    );
  }

  Widget _buildDateTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 30)),
              builder: (context, child) => Theme(
                data: ThemeData.dark().copyWith(
                    colorScheme: ColorScheme.dark(primary: primaryTurquoise)),
                child: child!,
              ),
            );
            if (picked != null) {
              setState(() => selectedDate = picked);
              _checkAvailability();
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                Icon(Icons.calendar_month, color: primaryTurquoise),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // GRILLE DES CRÉNEAUX AVEC COULEURS DYNAMIQUES
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: availableSlots.map((slot) {
            bool isTaken = takenSlots.contains(slot);
            bool isSelected = selectedSlot == slot;

            return ChoiceChip(
              label: Text(slot),
              selected: isSelected,
              onSelected: isTaken
                  ? null
                  : (selected) {
                      setState(() => selectedSlot = selected ? slot : null);
                    },
              // Couleurs de fond
              selectedColor: primaryTurquoise,
              disabledColor: occupiedRed.withOpacity(0.15),
              backgroundColor: availableGreen.withOpacity(0.1),

              // Style du texte
              labelStyle: TextStyle(
                color: isTaken
                    ? occupiedRed
                    : (isSelected ? Colors.white : availableGreen),
                fontWeight: FontWeight.bold,
                decoration: isTaken ? TextDecoration.lineThrough : null,
              ),

              // Bordures
              side: BorderSide(
                  color: isTaken
                      ? occupiedRed.withOpacity(0.4)
                      : (isSelected
                          ? primaryTurquoise
                          : availableGreen.withOpacity(0.4))),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _infoCard(IconData icon, String value, String label,
      {Color? iconColor}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor ?? primaryTurquoise, size: 28),
            const SizedBox(height: 10),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Text(label,
                style: const TextStyle(color: Colors.white38, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        widget.salle.description.isNotEmpty
            ? widget.salle.description
            : "Aucune description disponible.",
        style: TextStyle(
            color: Colors.white.withOpacity(0.6), height: 1.6, fontSize: 14),
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 10, 25, 30),
      child: SizedBox(
        height: 65,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isLoading ? null : reserverSalle,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryTurquoise,
            disabledBackgroundColor: Colors.white10,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 10,
          ),
          child: isLoading
              ? const CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 3)
              : const Text("CONFIRMER LA RÉSERVATION",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16)),
        ),
      ),
    );
  }

  void _showCustomSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isError ? occupiedRed : primaryTurquoise,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.all(15),
      ),
    );
  }
}
