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

  List<Salle> allSalles = [];
  List<Salle> filteredSalles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadSalles();
  }

  Future<void> loadSalles() async {
    setState(() => isLoading = true);
    try {
      allSalles = await apiService.getAllSalles();

      // Vérifier disponibilité de chaque salle (aujourd'hui)
      DateTime today = DateTime.now();
      for (var salle in allSalles) {
        salle.reservee =
            !(await apiService.verifierDisponibilite(salle.id, today));
      }

      setState(() {
        filteredSalles = allSalles;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("Erreur chargement salles : $e");
    }
  }

  void filtrerSalles(String query) {
    if (query.isEmpty) {
      setState(() => filteredSalles = allSalles);
    } else {
      final result = allSalles
          .where(
              (salle) => salle.nom.toLowerCase().contains(query.toLowerCase()))
          .toList();
      setState(() => filteredSalles = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff6a11cb), Color(0xff2575fc)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Réserver une salle",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),

                  /// SEARCH BAR
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10)
                        ]),
                    child: TextField(
                      onChanged: filtrerSalles,
                      decoration: const InputDecoration(
                          hintText: "Rechercher une salle...",
                          prefixIcon: Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 15)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            /// LISTE
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredSalles.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.75),
                      itemBuilder: (context, index) {
                        final salle = filteredSalles[index];
                        final imagePath = salle.image.isNotEmpty
                            ? "assets/images/${salle.image}"
                            : "assets/images/default.jpg";

                        return GestureDetector(
                          onTap: () async {
                            // Ouvrir detail salle
                            bool? updated = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => DetailsSalleScreen(
                                          salle: salle,
                                          utilisateurEmail:
                                              widget.utilisateurEmail,
                                        )));
                            if (updated == true) {
                              // Après réservation, recharger la disponibilité
                              loadSalles();
                            }
                          },
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  imagePath,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.7)
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: salle.reservee
                                        ? Colors.redAccent
                                        : Colors.green,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    salle.reservee ? "Occupée" : "Libre",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 12,
                                left: 12,
                                right: 12,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(salle.nom,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    Text("${salle.capacite} places",
                                        style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13)),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
