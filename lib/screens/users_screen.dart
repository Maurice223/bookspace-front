import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<dynamic> allUsers = [];
  List<dynamic> filteredUsers = [];
  bool isLoading = true;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  // ================= API =================
  Future<void> fetchUsers() async {
    setState(() => isLoading = true);

    try {
      final response =
          await http.get(Uri.parse('http://192.168.100.8:8080/utilisateurs'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          allUsers = data;
          filteredUsers = data;
          isLoading = false;
        });
      } else {
        throw Exception('Erreur récupération utilisateurs');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur API: $e")),
      );
    }
  }

  // ================= DELETE =================
  Future<void> deleteUser(int id) async {
    try {
      final response = await http.delete(
          Uri.parse('http://192.168.100.8:8080/utilisateurs/delete/$id'));

      if (response.statusCode == 200 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Utilisateur supprimé")),
        );
        fetchUsers();
      } else {
        throw Exception("Erreur suppression");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur suppression: $e")),
      );
    }
  }

  // ================= SEARCH =================
  void filterUsers(String query) {
    final results = allUsers.where((u) {
      final nom = (u['nom'] ?? '').toLowerCase();
      final email = (u['email'] ?? '').toLowerCase();
      return nom.contains(query.toLowerCase()) ||
          email.contains(query.toLowerCase());
    }).toList();

    setState(() => filteredUsers = results);
  }

  // ================= CONFIRM DELETE =================
  void confirmDelete(int id, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Confirmation"),
        content: Text("Supprimer l'utilisateur $name ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              deleteUser(id);
            },
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // 🔥 TITLE
              const Text(
                "Gestion des utilisateurs",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                        blurRadius: 6,
                        color: Colors.black45,
                        offset: Offset(1, 2))
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 🔍 SEARCH
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: searchController,
                  onChanged: filterUsers,
                  decoration: InputDecoration(
                    hintText: "Rechercher un utilisateur...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.95),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 📋 LIST USERS
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white))
                    : filteredUsers.isEmpty
                        ? const Center(
                            child: Text(
                              "Aucun utilisateur trouvé",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: filteredUsers.length,
                            itemBuilder: (context, index) {
                              final u = filteredUsers[index];

                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),

                                  // 👤 AVATAR
                                  leading: CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.deepPurple,
                                    child: Text(
                                      u['nom'] != null && u['nom'].isNotEmpty
                                          ? u['nom'][0].toUpperCase()
                                          : "?",
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),

                                  // INFOS
                                  title: Text(
                                    '${u['nom'] ?? ''} ${u['prenom'] ?? ''}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(u['email'] ?? ''),

                                  // ACTIONS
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () =>
                                        confirmDelete(u['id'], u['nom'] ?? ''),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
