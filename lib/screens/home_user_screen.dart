import 'dart:ui';
import 'package:bookspace/screens/login_screen.dart';
import 'package:flutter/material.dart';
import '../models/reservation.dart';
import 'reserver_screen.dart';
import 'mes_reservations_screen.dart';
import 'profil_screen.dart';
import '../services/api_service.dart';

class HomeUserScreen extends StatefulWidget {
  final String utilisateurEmail;

  const HomeUserScreen({super.key, required this.utilisateurEmail});

  @override
  State<HomeUserScreen> createState() => _HomeUserScreenState();
}

class _HomeUserScreenState extends State<HomeUserScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final ApiService apiService = ApiService();
  late Future<List<Reservation>> futureReservations;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  /// 🔥 animation badge
  double badgeScale = 1;

  @override
  void initState() {
    super.initState();

    futureReservations =
        apiService.getReservationsUtilisateur(widget.utilisateurEmail);

    /// animations page
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(_controller);

    _controller.forward();
  }

  /// 🔥 REFRESH GLOBAL
  void refreshReservations() {
    setState(() {
      futureReservations =
          apiService.getReservationsUtilisateur(widget.utilisateurEmail);

      /// animation badge bounce
      badgeScale = 1.3;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        badgeScale = 1;
      });
    });
  }

  // ---------------- ACCUEIL ----------------
  Widget _buildAccueil() {
    return FutureBuilder<List<Reservation>>(
      future: futureReservations,
      builder: (context, snapshot) {
        List<Reservation> reservations = [];
        Reservation? prochaineReservation;

        if (snapshot.hasData) {
          reservations = snapshot.data!;
          if (reservations.isNotEmpty) {
            prochaineReservation = reservations[0];
          }
        }

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff0f2027), Color(0xff203a43), Color(0xff2c5364)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                refreshReservations();
              },
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// HEADER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    widget.utilisateurEmail[0].toUpperCase(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.indigo),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Bienvenue 👋",
                                        style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.7))),
                                    Text(
                                      widget.utilisateurEmail.split('@')[0],
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                )
                              ],
                            ),

                            /// 🔔 BADGE ANIMÉ
                            Stack(
                              children: [
                                const Icon(Icons.notifications,
                                    color: Colors.white, size: 28),
                                if (reservations.isNotEmpty)
                                  Positioned(
                                    right: 0,
                                    child: AnimatedScale(
                                      scale: badgeScale,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle),
                                        child: Text(
                                          "${reservations.length}",
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10),
                                        ),
                                      ),
                                    ),
                                  )
                              ],
                            )
                          ],
                        ),

                        const SizedBox(height: 30),

                        /// STATS
                        Row(
                          children: [
                            _statCard(
                                "Total", "${reservations.length}", Icons.list),
                            const SizedBox(width: 10),
                            _statCard(
                                "Actif",
                                reservations.isNotEmpty ? "Oui" : "Non",
                                Icons.check_circle),
                          ],
                        ),

                        const SizedBox(height: 25),

                        /// PROCHAINE RESERVATION
                        _glassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("📅 Prochaine réservation",
                                  style: TextStyle(color: Colors.white)),
                              const SizedBox(height: 10),
                              Text(
                                prochaineReservation?.salleNom ??
                                    "Aucune réservation",
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 16),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        const Text("⚡ Actions rapides",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),

                        const SizedBox(height: 15),

                        GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _actionCard(Icons.meeting_room, "Réserver",
                                () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ReserverScreen(
                                      utilisateurEmail:
                                          widget.utilisateurEmail),
                                ),
                              );

                              refreshReservations(); // 🔥
                            }),
                            _actionCard(Icons.list, "Mes réservations",
                                () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MesReservationsScreen(
                                      email: widget.utilisateurEmail),
                                ),
                              );

                              refreshReservations(); // 🔥
                            }),
                            _actionCard(Icons.person, "Profil", () {
                              setState(() => _currentIndex = 3);
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// STAT CARD
  Widget _statCard(String title, String value, IconData icon) {
    return Expanded(
      child: _glassCard(
        child: Column(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  /// ACTION CARD
  Widget _actionCard(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: _glassCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 5),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  /// GLASS EFFECT
  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildAccueil(),
      ReserverScreen(utilisateurEmail: widget.utilisateurEmail),
      MesReservationsScreen(email: widget.utilisateurEmail),
      ProfilScreen(utilisateurEmail: widget.utilisateurEmail),
      _buildLogoutTab(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.indigoAccent,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          if (index == 0) {
            refreshReservations(); // 🔥 auto refresh
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.meeting_room), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: ""),
        ],
      ),
    );
  }

  Widget _buildLogoutTab() {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LoginScreen()),
          );
        },
        child: const Text("Se déconnecter"),
      ),
    );
  }
}
