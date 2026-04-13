import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/utilisateur.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final ApiService apiService = ApiService();

  // Palette de couleurs Premium
  final Color primaryColor = const Color(0xFF26A69A); // Turquoise
  final Color secondaryColor = const Color(0xFF4FC3F7); // Bleu ciel
  final Color darkBg = const Color(0xFF0F172A); // Bleu nuit profond

  List<Utilisateur> allUsers = [];
  List<Utilisateur> filteredUsers = [];
  bool isLoading = true;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final data = await apiService.getAllUtilisateurs();
      if (mounted) {
        setState(() {
          allUsers = data;
          filteredUsers = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ================= RECHERCHE NOM + PRENOM =================
  void filterUsers(String query) {
    final String q = query.toLowerCase();

    final results = allUsers.where((u) {
      final String fullSearch = "${u.nom} ${u.prenom}".toLowerCase();
      // On cherche dans le nom, le prénom, ET la combinaison des deux
      return fullSearch.contains(q) ||
          (u.nom?.toLowerCase().contains(q) ?? false) ||
          (u.prenom?.toLowerCase().contains(q) ?? false);
    }).toList();

    setState(() => filteredUsers = results);
  }

  // ================= UI COMPONENTS =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          // Background décoratif (Gradients diffus)
          Positioned(
              top: -100,
              right: -50,
              child: _buildBlurCircle(250, primaryColor.withOpacity(0.15))),
          Positioned(
              bottom: -50,
              left: -50,
              child: _buildBlurCircle(200, secondaryColor.withOpacity(0.1))),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildSearchBar(),
                Expanded(
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(color: primaryColor))
                      : _buildUserList(),
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
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Gestion Membres",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5)),
              Text("${filteredUsers.length} utilisateurs actifs",
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5), fontSize: 14)),
            ],
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15)),
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: loadUsers,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: TextField(
            controller: searchController,
            onChanged: filterUsers,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Rechercher par nom ou prénom...",
              hintStyle: const TextStyle(color: Colors.white24),
              prefixIcon: Icon(Icons.search_rounded, color: primaryColor),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              contentPadding: const EdgeInsets.symmetric(vertical: 20),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: primaryColor.withOpacity(0.3))),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserList() {
    if (filteredUsers.isEmpty) {
      return Center(
          child: Text("Aucun utilisateur trouvé",
              style: TextStyle(color: Colors.white.withOpacity(0.2))));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) => _buildUserCard(filteredUsers[index]),
    );
  }

  Widget _buildUserCard(Utilisateur u) {
    String initial =
        (u.nom != null && u.nom!.isNotEmpty) ? u.nom![0].toUpperCase() : "?";
    bool isAdmin = u.role?.toUpperCase() == "ADMIN";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar Stylisé
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient:
                        LinearGradient(colors: [primaryColor, secondaryColor]),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                      child: Text(initial,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold))),
                ),
                const SizedBox(width: 16),
                // Infos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${u.nom} ${u.prenom}",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(u.email ?? "",
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 13)),
                      const SizedBox(height: 8),
                      // Badge Role
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isAdmin ? Colors.orange : primaryColor)
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(u.role ?? "USER",
                            style: TextStyle(
                                color: isAdmin
                                    ? Colors.orangeAccent
                                    : primaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                ),
                // Actions
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: Colors.redAccent, size: 28),
                  onPressed: () {/* Ta fonction delete */},
                ),
              ],
            ),
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
          filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
          child: Container(color: Colors.transparent)),
    );
  }
}
