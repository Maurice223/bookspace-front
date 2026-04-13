import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/salle.dart';
import '../services/api_service.dart';
import 'details_salle_screen.dart';

class ReserverScreen extends StatefulWidget {
  final String utilisateurEmail;
  const ReserverScreen({super.key, required this.utilisateurEmail});

  @override
  State<ReserverScreen> createState() => _ReserverScreenState();
}

class _ReserverScreenState extends State<ReserverScreen> {
  final ApiService apiService = ApiService();
  final Color primaryTurquoise = const Color(0xFF26A69A);
  final Color darkBg = const Color(0xFF0F172A);

  List<Salle> allSalles = [];
  List<Salle> filteredSalles = [];
  bool isLoading = true;

  final List<Map<String, String>> slots = [
    {"start": "08:00", "end": "11:00"},
    {"start": "11:00", "end": "14:00"},
    {"start": "14:00", "end": "17:00"},
    {"start": "17:00", "end": "20:00"},
  ];

  @override
  void initState() {
    super.initState();
    loadSalles();
  }

  bool _isSlotPast(String endTime) {
    DateTime now = DateTime.now();
    List<String> parts = endTime.split(":");
    DateTime endDateTime = DateTime(
        now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
    return now.isAfter(endDateTime);
  }

  Future<void> loadSalles() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      allSalles = await apiService.getAllSalles();
      if (mounted) {
        setState(() {
          filteredSalles = allSalles;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          Positioned(
              top: -100,
              left: -50,
              child: _buildBlurCircle(250, primaryTurquoise.withOpacity(0.1))),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 10),
                _buildSearchBar(),
                const SizedBox(height: 20),
                Expanded(
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                              color: primaryTurquoise))
                      : _buildGrid(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Explorer",
              style: TextStyle(
                  color: primaryTurquoise,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2)),
          const Text("Nos Salles",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: TextField(
              onChanged: (v) => setState(() => filteredSalles = allSalles
                  .where((s) => s.nom.toLowerCase().contains(v.toLowerCase()))
                  .toList()),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Rechercher une salle...",
                hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.3), fontSize: 14),
                prefixIcon: Icon(Icons.search_rounded,
                    color: primaryTurquoise, size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filteredSalles.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) => _buildSalleCard(filteredSalles[index]),
    );
  }

  Widget _buildSalleCard(Salle salle) {
    final imagePath = salle.image.isNotEmpty
        ? "assets/images/${salle.image}"
        : "assets/images/default.jpg";

    // ✅ Logique pour le type de salle
    bool isTP = salle.type.toUpperCase() == "TP";

    return GestureDetector(
      onTap: () async {
        bool? updated = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => DetailsSalleScreen(
                    salle: salle, utilisateurEmail: widget.utilisateurEmail)));
        if (updated == true) loadSalles();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5))
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Stack(
            children: [
              Positioned.fill(child: Image.asset(imagePath, fit: BoxFit.cover)),
              Positioned.fill(
                  child: Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.95)
                  ])))),

              // ✅ BADGE DE TYPE (TP / COURS)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isTP
                        ? Colors.purpleAccent.withOpacity(0.8)
                        : Colors.blueAccent.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    children: [
                      Icon(isTP ? Icons.computer_rounded : Icons.school_rounded,
                          color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text(isTP ? "TP" : "COURS",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),

              // CONTENU
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(salle.nom,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text("Aujourd'hui :",
                        style: TextStyle(color: Colors.white38, fontSize: 9)),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: slots.map((slot) {
                        bool isPast = _isSlotPast(slot['end']!);
                        bool isOccupied = salle.reservee && !isPast;

                        return Container(
                          width: 32,
                          height: 3,
                          decoration: BoxDecoration(
                            color: isPast
                                ? Colors.white10
                                : (isOccupied
                                    ? Colors.redAccent
                                    : primaryTurquoise),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.people_outline,
                            color: primaryTurquoise, size: 12),
                        const SizedBox(width: 4),
                        Text("${salle.capacite} places",
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBlurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(color: Colors.transparent)),
    );
  }
}
