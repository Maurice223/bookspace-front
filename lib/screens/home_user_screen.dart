import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reservation.dart';
import '../models/salle.dart';
import '../services/api_service.dart';
import 'reserver_screen.dart';
import 'mes_reservations_screen.dart';
import 'profil_screen.dart';
import 'notification_inbox_screen.dart';

class HomeUserScreen extends StatefulWidget {
  final String utilisateurEmail;

  const HomeUserScreen({super.key, required this.utilisateurEmail});

  @override
  State<HomeUserScreen> createState() => _HomeUserScreenState();
}

class _HomeUserScreenState extends State<HomeUserScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  int unreadMessagesCount = 0;
  final ApiService apiService = ApiService();

  late Future<List<Reservation>> futureReservations;
  late Future<List<Salle>> futureSalles;

  final Color primaryTurquoise = const Color(0xFF26A69A);
  final Color darkBg = const Color(0xFF0F172A);

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final List<String> _astuces = [
    "Pensez à libérer votre salle si vous terminez en avance ! 😊",
    "Vérifiez que vous avez bien éteint les lumières en partant. 💡",
    "Besoin d'un projecteur ? Les salles de cours en sont équipées. 🎥",
    "Pensez à prendre votre badge pour le bâtiment B. 🔑",
  ];
  late String _currentAstuce;

  @override
  void initState() {
    super.initState();
    _currentAstuce = _astuces[0];
    _loadData();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  void _loadData() {
    setState(() {
      futureReservations =
          apiService.getReservationsUtilisateur(widget.utilisateurEmail);
      futureSalles =
          apiService.getAllSalles(); // Utilise ta méthode getAllSalles()
      _currentAstuce = (_astuces..shuffle()).first;
    });
    _loadUnreadMessagesCount();
  }

  Future<void> _loadUnreadMessagesCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<dynamic> allMessages = await apiService.fetchMessages();
      List<String> readIds = prefs.getStringList('read_message_ids') ?? [];
      int count = allMessages
          .where((msg) => !readIds.contains(msg['id'].toString()))
          .length;
      setState(() {
        unreadMessagesCount = count;
      });
    } catch (e) {
      debugPrint("Erreur compteur: $e");
    }
  }

  // ---------------- 1. RECOMMANDATION IA (TOP OPTION) ----------------

  Widget _buildAIRecommendation(Salle? salle) {
    if (salle == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("✨ Sélectionné pour vous",
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        GestureDetector(
          onTap: () => setState(() => _currentIndex = 1),
          child: Container(
            width: double.infinity,
            height: 170,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                colors: [
                  primaryTurquoise.withOpacity(0.8),
                  Colors.blueAccent.withOpacity(0.6)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                    color: primaryTurquoise.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8))
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                    right: -10,
                    bottom: -10,
                    child: Icon(Icons.auto_awesome,
                        size: 120, color: Colors.white.withOpacity(0.1))),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10)),
                        child: const Text("CONSEILLÉ",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                      const Spacer(),
                      Text(salle.nom ?? "Salle",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.people_outline,
                              color: Colors.white70, size: 14),
                          const SizedBox(width: 5),
                          Text("${salle.capacite} places disponibles",
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 6),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Text("Réserver maintenant",
                            style: TextStyle(
                                color: primaryTurquoise,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- 2. TOUTES LES OPTIONS (LISTE COMPLÈTE) ----------------

  Widget _buildAllOptions(List<Salle> salles) {
    if (salles.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        const Text("🕒 Autres options disponibles",
            style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 15),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: salles.length,
            itemBuilder: (context, index) {
              final s = salles[index];
              return GestureDetector(
                onTap: () => setState(() => _currentIndex = 1),
                child: Container(
                  width: 150,
                  margin: const EdgeInsets.only(right: 15),
                  child: _glassContainer(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(s.nom ?? "Salle",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        Text("${s.capacite} places",
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 11)),
                        const SizedBox(height: 4),
                        Text(s.type ?? "Standard",
                            style: TextStyle(
                                color: primaryTurquoise,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ---------------- STRUCTURE D'ACCUEIL ----------------

  Widget _buildAccueil() {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([futureReservations, futureSalles]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError)
          return Center(
              child: Text("Erreur de connexion",
                  style: const TextStyle(color: Colors.white)));

        // Cast explicite pour éviter les erreurs type 'dynamic'
        final List<Reservation> reservations =
            (snapshot.data![0] as List).cast<Reservation>();
        final List<Salle> toutesLesSalles =
            (snapshot.data![1] as List).cast<Salle>();

        final prochaine = reservations.isNotEmpty ? reservations[0] : null;
        final recommandation =
            toutesLesSalles.isNotEmpty ? toutesLesSalles[0] : null;

        return RefreshIndicator(
          onRefresh: () async => _loadData(),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 30),
                  _buildNextReservation(prochaine),
                  const SizedBox(height: 30),

                  // Section IA (Prend la 1ère salle)
                  _buildAIRecommendation(recommandation),

                  // Section Toutes les salles (Affiche tout le catalogue)
                  _buildAllOptions(toutesLesSalles),

                  const SizedBox(height: 30),
                  _buildInfoBanner(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------- COMPOSANTS UI ----------------

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: primaryTurquoise.withOpacity(0.2),
              child: Text(widget.utilisateurEmail[0].toUpperCase(),
                  style: TextStyle(
                      color: primaryTurquoise, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Salut 👋",
                    style: TextStyle(color: Colors.white54, fontSize: 14)),
                Text(widget.utilisateurEmail.split('@')[0],
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
              ],
            )
          ],
        ),
        IconButton(
          icon: Badge(
            label: Text("$unreadMessagesCount"),
            isLabelVisible: unreadMessagesCount > 0,
            child: const Icon(Icons.notifications_none_rounded,
                color: Colors.white, size: 28),
          ),
          onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NotificationInboxScreen()))
              .then((_) => _loadUnreadMessagesCount()),
        ),
      ],
    );
  }

  Widget _buildNextReservation(Reservation? next) {
    return _glassContainer(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: primaryTurquoise.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15)),
            child: Icon(Icons.event_available_rounded,
                color: primaryTurquoise, size: 28),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Prochaine occupation",
                    style: TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 4),
                Text(next?.salleNom ?? "Aucune réservation",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                if (next != null)
                  Text(next.creneauHoraire ?? "",
                      style: TextStyle(color: primaryTurquoise, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassContainer({required Widget child, EdgeInsetsGeometry? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withOpacity(0.1))),
          child: child,
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return _glassContainer(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline_rounded,
              color: Colors.amberAccent, size: 28),
          const SizedBox(width: 15),
          Expanded(
              child: Text(_currentAstuce,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.7), fontSize: 13))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildAccueil(),
      ReserverScreen(utilisateurEmail: widget.utilisateurEmail),
      MesReservationsScreen(utilisateurEmail: widget.utilisateurEmail),
      ProfilScreen(utilisateurEmail: widget.utilisateurEmail),
    ];

    return Scaffold(
      backgroundColor: darkBg,
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: darkBg,
        selectedItemColor: primaryTurquoise,
        unselectedItemColor: Colors.white24,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded), label: "Acceuil"),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline_rounded), label: "Réserver"),
          BottomNavigationBarItem(
              icon: Icon(Icons.format_list_bulleted_rounded), label: "Liste"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: "Profil"),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
