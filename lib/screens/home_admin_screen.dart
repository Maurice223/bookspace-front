import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'admin_broadcast_screen.dart'; // ✅ Import de la page de création d'annonce

class HomeAdminScreen extends StatefulWidget {
  const HomeAdminScreen({super.key});

  @override
  State<HomeAdminScreen> createState() => _HomeAdminScreenState();
}

class _HomeAdminScreenState extends State<HomeAdminScreen> {
  final ApiService apiService = ApiService();
  final Color primaryTurquoise = const Color(0xFF26A69A);
  final Color darkBg = const Color(0xFF0F172A);

  int _currentIndex = 0;

  int nbSalles = 0;
  int nbUsers = 0;
  int nbReservations = 0;
  bool isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadRealStats();
  }

  Future<void> _loadRealStats() async {
    if (!mounted) return;
    setState(() => isLoadingStats = true);
    try {
      final results = await Future.wait([
        apiService.getAllSalles(),
        apiService.getAllUtilisateurs(),
        apiService.getAllReservations(),
      ]);

      if (mounted) {
        setState(() {
          nbSalles = (results[0] as List).length;
          nbUsers = (results[1] as List).length;
          nbReservations = (results[2] as List).length;
          isLoadingStats = false;
        });
      }
    } catch (e) {
      debugPrint("Erreur Stats: $e");
      if (mounted) setState(() => isLoadingStats = false);
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
            child: IndexedStack(
              index: _currentIndex,
              children: [
                _buildDashboard(),
                _buildSettingsTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildDashboard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildHeader(),
          const SizedBox(height: 30),
          _buildQuickStats(),
          const SizedBox(height: 30),
          const Text("Gestion du Système",
              style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 1.2)),
          const SizedBox(height: 15),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadRealStats,
              color: primaryTurquoise,
              backgroundColor: darkBg,
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.1,
                children: [
                  // ✅ NOUVELLE CARTE POUR DIFFUSER UNE ANNONCE
                  _modernCard("Diffuser Annonce", Icons.campaign_rounded,
                      Colors.orangeAccent, "broadcast"),
                  _modernCard("Utilisateurs", Icons.people_alt_rounded,
                      Colors.blueAccent, "/admin_users"),
                  _modernCard("Salles", Icons.meeting_room_rounded,
                      primaryTurquoise, "/admin_salles"),
                  _modernCard("Ajouter Salle", Icons.add_location_alt_rounded,
                      Colors.purpleAccent, "/admin_add_salle"),
                  _modernCard("Réservations", Icons.receipt_long_rounded,
                      Colors.redAccent, "/admin_reservations"),
                  _modernCard("Analyses", Icons.bar_chart_rounded,
                      Colors.greenAccent, "/admin_stats"),
                  _modernCard("Support", Icons.help_outline_rounded,
                      Colors.blueGrey, "coming_soon"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Panel de contrôle",
                style: TextStyle(
                    color: primaryTurquoise, fontWeight: FontWeight.bold)),
            const Text("Dashboard Admin",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900)),
          ],
        ),
        CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.05),
          child: IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _loadRealStats,
          ),
        )
      ],
    );
  }

  Widget _buildQuickStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _statItem(isLoadingStats ? "..." : "$nbSalles", "Salles"),
        _statItem(isLoadingStats ? "..." : "$nbUsers", "Users"),
        _statItem(isLoadingStats ? "..." : "$nbReservations", "Réserves"),
      ],
    );
  }

  Widget _statItem(String value, String label) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.28,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _modernCard(String title, IconData icon, Color color, String route) {
    return GestureDetector(
      onTap: () {
        if (route == "coming_soon") {
          _showComingSoon();
        } else if (route == "broadcast") {
          // ✅ Navigation vers la page d'annonce
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AdminBroadcastScreen()),
          );
        } else {
          Navigator.pushNamed(context, route);
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(15)),
                  child: Icon(icon, color: color, size: 26),
                ),
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(Icons.dashboard_rounded, 0),
          _navItem(Icons.settings_suggest_rounded, 1),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, int index) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryTurquoise.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon,
            color: isSelected ? primaryTurquoise : Colors.white38, size: 28),
      ),
    );
  }

  Widget _buildSettingsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.admin_panel_settings_outlined,
              size: 100, color: primaryTurquoise.withOpacity(0.2)),
          const SizedBox(height: 20),
          const Text("Configuration Admin",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),
          // ✅ BOUTON DECONNEXION AVEC POP-UP DE CONFIRMATION
          _glassButton("DÉCONNEXION", Icons.logout_rounded, Colors.redAccent,
              _showLogoutConfirm),
        ],
      ),
    );
  }

  // ✅ FONCTION DE DÉCONNEXION PROPRE
  void _showLogoutConfirm() {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title:
              const Text("Déconnexion", style: TextStyle(color: Colors.white)),
          content: const Text("Voulez-vous vraiment quitter la session Admin ?",
              style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Annuler")),
            TextButton(
              onPressed: () {
                // ✅ On nettoie la pile de navigation pour revenir au Login
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text("Quitter",
                  style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon() {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.construction_rounded,
                  color: primaryTurquoise, size: 50),
              const SizedBox(height: 20),
              const Text("Bientôt disponible",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glassButton(
      String text, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Text(text,
                style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
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
          filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
          child: Container(color: Colors.transparent)),
    );
  }
}
