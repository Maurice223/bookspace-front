import 'dart:ui';
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

  // ✅ On remplace le booléen par un String pour le type
  String selectedType = "COURS";

  final ApiService api = ApiService();
  bool isLoading = false;

  final Color primaryTurquoise = const Color(0xFF26A69A);
  final Color darkBg = const Color(0xFF0F172A);

  InputDecoration inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white60, fontSize: 14),
      prefixIcon: Icon(icon, color: primaryTurquoise, size: 20),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: primaryTurquoise, width: 1.5),
      ),
    );
  }

  void addSalle() async {
    if (nomController.text.isEmpty ||
        capaciteController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        imageUrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text("Veuillez remplir tous les champs")));
      return;
    }

    setState(() => isLoading = true);

    try {
      // ✅ APPEL API CORRIGÉ : On envoie le 'selectedType' (String)
      bool success = await api.addSalle(
        nomController.text,
        int.tryParse(capaciteController.text) ?? 0,
        imageUrlController.text,
        descriptionController.text,
        selectedType, // Passage du String "TP" ou "COURS"
      );

      setState(() => isLoading = false);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.green,
              content: Text("🎉 Salle créée avec succès !")));
          Navigator.pop(context, true);
        }
      } else {
        throw Exception("Erreur serveur");
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text("Erreur lors de la création de la salle")));
      }
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
              right: -50,
              child: _buildBlurCircle(250, primaryTurquoise.withOpacity(0.1))),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: _buildFormCard(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Text("Nouvelle Salle",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
              controller: nomController,
              style: const TextStyle(color: Colors.white),
              decoration:
                  inputStyle("Nom de la salle", Icons.meeting_room_rounded)),
          const SizedBox(height: 15),
          TextField(
              controller: capaciteController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: inputStyle("Capacité", Icons.people_alt_rounded)),

          const SizedBox(height: 15),
          // ✅ NOUVEAU : SÉLECTEUR DE TYPE (TP / COURS)
          _buildTypeSelector(),

          const SizedBox(height: 15),
          TextField(
              controller: descriptionController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: inputStyle("Description", Icons.description_rounded)),
          const SizedBox(height: 15),
          TextField(
              controller: imageUrlController,
              style: const TextStyle(color: Colors.white),
              decoration:
                  inputStyle("Image (ex: salle1.jpg)", Icons.image_rounded)),
          const SizedBox(height: 30),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  // ✅ Widget pour choisir entre TP et COURS
  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedType,
          dropdownColor: darkBg,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: primaryTurquoise),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          items: ["COURS", "TP"].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              selectedType = newValue!;
            });
          },
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: isLoading ? null : addSalle,
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          gradient:
              LinearGradient(colors: [primaryTurquoise, Colors.blueAccent]),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("CRÉER LA SALLE",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2)),
        ),
      ),
    );
  }

  Widget _buildBlurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
