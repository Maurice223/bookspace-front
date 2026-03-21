import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SallesScreen extends StatefulWidget {
  const SallesScreen({super.key});

  @override
  State<SallesScreen> createState() => _SallesScreenState();
}

class _SallesScreenState extends State<SallesScreen> {
  List<dynamic> allSalles = [];
  List<dynamic> filteredSalles = [];
  bool isLoading = true;

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchSalles();
  }

  Future<void> fetchSalles() async {
    setState(() => isLoading = true);

    try {
      final response =
          await http.get(Uri.parse('http://192.168.100.8:8080/salles'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          allSalles = data;
          filteredSalles = data;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        throw Exception('Erreur récupération salles');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur API: $e')));
    }
  }

  void filterSalles(String query) {
    final results = allSalles.where((s) {
      final nom = (s['nom'] ?? '').toLowerCase();
      return nom.contains(query.toLowerCase());
    }).toList();

    setState(() => filteredSalles = results);
  }

  Future<void> deleteSalle(int id) async {
    try {
      final response = await http
          .delete(Uri.parse('http://192.168.100.8:8080/salles/delete/$id'));

      if (response.statusCode == 200 || response.statusCode == 204) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Salle supprimée")));
        fetchSalles();
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Erreur suppression")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erreur API: $e")));
    }
  }

  void confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Confirmation"),
        content: const Text("Supprimer cette salle ?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              deleteSalle(id);
            },
            child: const Text(
              "Supprimer",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 50),
            const Text(
              "Gestion des Salles",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: searchController,
                onChanged: filterSalles,
                decoration: InputDecoration(
                  hintText: "Rechercher...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredSalles.isEmpty
                      ? const Center(
                          child: Text(
                            "Aucune salle",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredSalles.length,
                          itemBuilder: (context, index) {
                            final s = filteredSalles[index];

                            return Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),

                                // IMAGE DE L'ASSET
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: s['image'] != null &&
                                          s['image'].isNotEmpty
                                      ? Image.asset(
                                          'assets/images/${s['image']}',
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          width: 50,
                                          height: 50,
                                          color: Colors.grey.shade300,
                                          child: const Icon(Icons.meeting_room,
                                              color: Colors.white),
                                        ),
                                ),

                                title: Text(
                                  s['nom'] ?? '',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  "Capacité: ${s['capacite'] ?? 0}\n${s['description'] ?? ''}",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => confirmDelete(s['id']),
                                ),
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
