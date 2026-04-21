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

  final Color primaryColor = const Color(0xFF26A69A); 
  final Color secondaryColor = const Color(0xFF4FC3F7); 
  final Color darkBg = const Color(0xFF0F172A); 

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

  // ✅ FONCTION DE SUPPRESSION
  void confirmDelete(Utilisateur u) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Supprimer ?", style: TextStyle(color: Colors.white)),
        content: Text("Voulez-vous vraiment supprimer ${u.prenom} ${u.nom} ?",
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(context); // Fermer le dialogue
              setState(() => isLoading = true);
              
              // On suppose que l'ID est dans u.id
              bool success = await apiService.deleteUtilisateur(u.id!); 
              
              if (success) {
                _showSnackBar("Utilisateur supprimé avec succès", isError: false);
                loadUsers(); // Recharger la liste
              } else {
                setState(() => isLoading = false);
                _showSnackBar("Erreur lors de la suppression", isError: true);
              }
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void filterUsers(String query) {
    final String q = query.toLowerCase();
    final results = allUsers.where((u) {
      final String fullSearch = "${u.nom} ${u.prenom}".toLowerCase();
      return fullSearch.contains(q) ||
          (u.nom?.toLowerCase().contains(q) ?? false) ||
          (u.prenom?.toLowerCase().contains(q) ?? false);
    }).toList();
    setState(() => filteredUsers = results);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          Positioned(top: -100, right: -50, child: _buildBlurCircle(250, primaryColor.withOpacity(0.15))),
          Positioned(bottom: -50, left: -50, child: _buildBlurCircle(200, secondaryColor.withOpacity(0.1))),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildSearchBar(),
                Expanded(
                  child: isLoading
                      ? Center(child: CircularProgressIndicator(color: primaryColor))
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
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              Text("${filteredUsers.length} utilisateurs actifs",
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: loadUsers,
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
              hintText: "Rechercher un membre...",
              hintStyle: const TextStyle(color: Colors.white24),
              prefixIcon: Icon(Icons.search_rounded, color: primaryColor),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserList() {
    if (filteredUsers.isEmpty) {
      return Center(child: Text("Aucun résultat", style: TextStyle(color: Colors.white.withOpacity(0.2))));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) => _buildUserCard(filteredUsers[index]),
    );
  }

  Widget _buildUserCard(Utilisateur u) {
    String initial = (u.nom != null && u.nom!.isNotEmpty) ? u.nom![0].toUpperCase() : "?";
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
                Container(
                  width: 55, height: 55,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [primaryColor, secondaryColor]),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${u.nom} ${u.prenom}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text(u.email ?? "", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                    ],
                  ),
                ),
                // ✅ ACTION SUPPRIMER CONNECTÉE
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  onPressed: () => confirmDelete(u),
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
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}