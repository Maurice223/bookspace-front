import 'dart:ui'; // Obligatoire pour BackdropFilter (effet flou)
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SallesScreen extends StatefulWidget {
  const SallesScreen({super.key});

  @override
  State<SallesScreen> createState() => _SallesScreenState();
}

class _SallesScreenState extends State<SallesScreen> {
  final ApiService apiService = ApiService();

  // COULEURS DU THÈME PREMIUM (Cohérent avec le Dashboard)
  final Color primaryTurquoise = const Color(0xFF26A69A);
  final Color darkBg = const Color(0xFF0F172A);
  final Color cardBg = Colors.white.withOpacity(0.05);

  List<dynamic> allSalles = [];
  List<dynamic> filteredSalles = [];
  bool isLoading = true;

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchSalles();
  }

  // 🔹 LOGIQUE API (Identique, on ne change que l'UI)
  Future<void> fetchSalles() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final data = await apiService.getAllSalles();
      if (mounted) {
        setState(() {
          allSalles = data;
          filteredSalles = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.redAccent,
              content: Text('Erreur : Impossible de charger les salles ($e)')),
        );
      }
    }
  }

  void filterSalles(String query) {
    final results = allSalles.where((s) {
      final String nom = (s is Map ? s['nom'] : s.nom ?? '').toLowerCase();
      return nom.contains(query.toLowerCase());
    }).toList();
    setState(() => filteredSalles = results);
  }

  Future<void> deleteSalle(int id) async {
    try {
      // Assure-toi que deleteSalle est dans ton api_service.dart
      await apiService.deleteSalle(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Salle supprimée avec succès")),
        );
        fetchSalles();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.redAccent,
              content: Text("Erreur de suppression")),
        );
      }
    }
  }

  void confirmDelete(int id, String nome) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Supprimer $nome ?",
            style: const TextStyle(color: Colors.white)),
        content: const Text(
            "Voulez-vous vraiment supprimer cette salle ? Cette action est irréversible.",
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text("Annuler", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              deleteSalle(id);
            },
            child:
                const Text("Supprimer", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- DESIGN DES CARTES "GLASSMORPHISM" ---
  Widget buildSalleCard(dynamic s) {
    // S'adapte si s est un objet Salle ou un Map JSON
    final String nom = s is Map ? s['nom'] : s.nom ?? 'Inconnue';
    final int id = s is Map ? s['id'] : s.id;
    final String img = s is Map ? s['image'] : s.image ?? 'default.png';
    final int cap = s is Map ? s['capacite'] : s.capacite ?? 0;
    final String desc = s is Map ? s['description'] : s.description ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cardBg, // Fond très légèrement translucide
        borderRadius: BorderRadius.circular(25),
        border:
            Border.all(color: Colors.white.withOpacity(0.08)), // Bordure fine
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          // Effet de flou derrière la carte (Glass)
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: ExpansionTile(
            // ExpansionTile pour voir la description au clic
            tilePadding: const EdgeInsets.all(12),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,

            // Image de la Salle
            leading: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: img.isNotEmpty
                    ? Image.asset('assets/images/$img',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => _buildFallbackIcon())
                    : _buildFallbackIcon(),
              ),
            ),

            // Infos Principales
            title: Text(nom,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white)),
            subtitle: Text("Capacité : $cap personnes",
                style: TextStyle(
                    color: primaryTurquoise, fontWeight: FontWeight.bold)),

            // Bouton Suppression
            trailing: IconButton(
              icon: const Icon(Icons.delete_sweep_rounded,
                  color: Colors.redAccent, size: 28),
              onPressed: () => confirmDelete(id, nom),
            ),

            // Description cachée (s'affiche au clic)
            children: [
              const Divider(color: Colors.white10),
              const SizedBox(height: 8),
              Text(
                  desc.isEmpty
                      ? "Aucune description fournie pour cette salle."
                      : desc,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 14, height: 1.4)),
              const SizedBox(height: 10),
              // Boutons d'action supplémentaires (optionnel)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {}, // Ajouter action éditer ici
                    icon: const Icon(Icons.edit_note_rounded,
                        color: Colors.white54, size: 18),
                    label: const Text("ÉDITER",
                        style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // Icone de remplacement si pas d'image
  Widget _buildFallbackIcon() {
    return Container(
        width: 60,
        height: 60,
        color: Colors.white10,
        child: const Icon(Icons.meeting_room_rounded,
            color: Colors.white24, size: 30));
  }

  // --- BUILD PRINCIPAL ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg, // Fond sombre Premium
      appBar: AppBar(
        title: const Text("Gestion des Salles",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 24)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            onPressed: fetchSalles,
          )
        ],
      ),

      // Utilisation d'un Stack pour les halos d'arrière-plan subtils
      body: Stack(
        children: [
          // Halo turquoise en haut à gauche
          Positioned(
              top: -80,
              left: -80,
              child: _buildBlurCircle(200, primaryTurquoise.withOpacity(0.08))),

          Column(
            children: [
              const SizedBox(height: 15),

              // SEARCH BAR MODERNISÉE
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: searchController,
                  onChanged: filterSalles,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Rechercher une salle (ex: VIP, Conférence)...",
                    hintStyle: const TextStyle(color: Colors.white38),
                    prefixIcon:
                        Icon(Icons.search_rounded, color: primaryTurquoise),
                    filled: true,
                    fillColor: Colors.white
                        .withOpacity(0.03), // Fond sombre translucide
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide:
                            BorderSide(color: Colors.white.withOpacity(0.05))),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                            color: primaryTurquoise.withOpacity(0.5))),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // LISTE DES SALLES
              Expanded(
                child: isLoading
                    ? Center(
                        child:
                            CircularProgressIndicator(color: primaryTurquoise))
                    : filteredSalles.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.meeting_room_outlined,
                                    size: 80, color: Colors.white10),
                                const SizedBox(height: 16),
                                Text("Aucune salle trouvée",
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.3),
                                        fontSize: 18)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredSalles.length,
                            padding: const EdgeInsets.only(top: 10, bottom: 30),
                            itemBuilder: (context, index) =>
                                buildSalleCard(filteredSalles[index]),
                          ),
              ),
            ],
          ),
        ],
      ),

      // Bouton flottant pour ajouter une salle (Optionnel, cohérent avec le thème)
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryTurquoise,
        onPressed: () => Navigator.pushNamed(context, "/admin_add_salle"),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
      ),
    );
  }

  // Widget pour créer les halos d'arrière-plan
  Widget _buildBlurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
          child: Container(color: Colors.transparent)),
    );
  }
}
