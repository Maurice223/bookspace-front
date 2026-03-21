import 'package:flutter/material.dart';

class HomeAdminScreen extends StatefulWidget {
  const HomeAdminScreen({super.key});

  @override
  State<HomeAdminScreen> createState() => _HomeAdminScreenState();
}

class _HomeAdminScreenState extends State<HomeAdminScreen> {
  bool isDark = true;
  int _currentIndex = 0;

  Widget modernCard(String title, IconData icon, Color color, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.04)
              : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.4)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            Text(
              title,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Dashboard Admin",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.logout,
                  color: isDark ? Colors.white : Colors.black),
              onPressed: () {
                // Redirection simple vers login
                Navigator.pushReplacementNamed(context, "/");
              },
            ),
            Switch(
              value: isDark,
              activeColor: Colors.blue,
              onChanged: (v) {
                setState(() {
                  isDark = v;
                });
              },
            ),
          ],
        )
      ],
    );
  }

  Drawer buildAdminDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              isDark ? Color(0xFF0A0F1C) : Color(0xFFF8FAFC),
              isDark ? Color(0xFF121A2B) : Color(0xFFE2E8F0)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius:
                    const BorderRadius.only(bottomRight: Radius.circular(40)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.admin_panel_settings,
                        size: 40, color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Administrateur",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.white),
              title:
                  const Text("Accueil", style: TextStyle(color: Colors.white)),
              onTap: () =>
                  Navigator.pushReplacementNamed(context, "/home_admin"),
            ),
            ListTile(
              leading: const Icon(Icons.people, color: Colors.white),
              title: const Text("Utilisateurs",
                  style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pushNamed(context, "/admin_users"),
            ),
            ListTile(
              leading: const Icon(Icons.meeting_room, color: Colors.white),
              title:
                  const Text("Salles", style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pushNamed(context, "/admin_salles"),
            ),
          ],
        ),
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
          Navigator.pushReplacementNamed(context, "/login");
        },
        child: const Text("Se déconnecter"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _dashboard(),
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
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: ""),
        ],
      ),
    );
  }

  Widget _dashboard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isDark ? Color(0xFF0A0F1C) : Color(0xFFF8FAFC),
            isDark ? Color(0xFF121A2B) : Color(0xFFE2E8F0)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              header(),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    modernCard("Utilisateurs", Icons.people, Colors.blue,
                        "/admin_users"),
                    modernCard("Salles", Icons.meeting_room, Colors.green,
                        "/admin_salles"),
                    modernCard("Ajouter Salle", Icons.add_business,
                        Colors.purple, "/admin_add_salle"),
                    modernCard("Réservations", Icons.book_online, Colors.orange,
                        "/admin_reservations"),
                    modernCard("Statistiques", Icons.bar_chart, Colors.red,
                        "/admin_stats"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
