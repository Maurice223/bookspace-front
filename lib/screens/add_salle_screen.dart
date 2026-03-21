import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddSallePage extends StatefulWidget {
  const AddSallePage({super.key});

  @override
  State<AddSallePage> createState() => _AddSallePageState();
}

class _AddSallePageState extends State<AddSallePage> {
  final TextEditingController nomController = TextEditingController();
  final TextEditingController capaciteController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  final ApiService api = ApiService();

  bool isLoading = false;
  bool isDark = true;

  InputDecoration inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
      filled: true,
      fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }

  void addSalle() async {
    if (nomController.text.isEmpty ||
        capaciteController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        imageUrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tous les champs sont requis")));
      return;
    }

    setState(() => isLoading = true);

    bool success = await api.addSalle(
      nomController.text,
      int.tryParse(capaciteController.text) ?? 0,
      imageUrlController.text,
      descriptionController.text,
    );

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success ? "Salle ajoutée" : "Erreur ajout salle")));

    if (success) {
      nomController.clear();
      capaciteController.clear();
      imageUrlController.clear();
      descriptionController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                : [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Ajouter une salle",
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Switch(
                      value: isDark,
                      onChanged: (v) {
                        setState(() {
                          isDark = v;
                        });
                      },
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                          controller: nomController,
                          style: TextStyle(
                              color: isDark ? Colors.white : Colors.black),
                          decoration: inputStyle("Nom de la salle"),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: capaciteController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                              color: isDark ? Colors.white : Colors.black),
                          decoration: inputStyle("Capacité"),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: descriptionController,
                          style: TextStyle(
                              color: isDark ? Colors.white : Colors.black),
                          decoration: inputStyle("Description"),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: imageUrlController,
                          style: TextStyle(
                              color: isDark ? Colors.white : Colors.black),
                          decoration: inputStyle("URL de l'image"),
                        ),
                        const SizedBox(height: 25),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onPressed: isLoading ? null : addSalle,
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text(
                                    "Ajouter",
                                    style: TextStyle(fontSize: 16),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
