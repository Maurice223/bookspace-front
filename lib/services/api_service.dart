import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/utilisateur.dart';
import '../models/salle.dart';
import '../models/reservation.dart';

class ApiService {
  final String baseUrl = "https://bookspace-backend-production.up.railway.app";

  // ------------------ UTILISATEUR ------------------

  Future<int> register(String prenom, String nom, String email, String password,
      String nomUtilisateur, String telephone) async {
    final url = Uri.parse('$baseUrl/utilisateurs');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "prenom": prenom,
          "nom": nom,
          "email": email,
          "password": password,
          "nomUtilisateur": nomUtilisateur,
          "telephone": telephone,
          "role": "USER",
        }),
      );
      return response.statusCode;
    } catch (e) {
      return 0;
    }
  }

  Future<Map<String, dynamic>?> login(
      String nomUtilisateur, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/utilisateurs/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
            {"nomUtilisateur": nomUtilisateur, "password": password}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Erreur connexion login: $e");
    }
    return null;
  }

  Future<Utilisateur?> getUtilisateur(String username) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/utilisateurs/$username'));
      if (response.statusCode == 200) {
        return Utilisateur.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ------------------ SALLE ------------------

  Future<List<Salle>> getAllSalles() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/salles"));
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map<Salle>((e) => Salle.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ✅ AJOUT D'UNE SALLE (Mise à jour pour inclure le TYPE)
  Future<bool> addSalle(String nom, int capacite, String image,
      String description, String type) async {
    final response = await http.post(
      Uri.parse('$baseUrl/salles'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "nom": nom,
        "capacite": capacite,
        "image": image,
        "description": description,
        "type": type, // "TP" ou "COURS"
        "reservee": false,
      }),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> deleteSalle(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/salles/delete/$id"));
    return response.statusCode == 200 || response.statusCode == 204;
  }

  // ------------------ RÉSERVATION (LOGIQUE 3H) ------------------

  // ✅ MISE À JOUR : Envoie un JSON avec Date et Créneau
  Future<bool> reserverSalleAvecDate(
      int salleId, String email, DateTime date, String creneau) async {
    final formattedDate =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    final url = Uri.parse("$baseUrl/reservations/reserver");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "salleId": salleId,
          "utilisateurEmail": email,
          "date": formattedDate,
          "creneau": creneau, // Ex: "08:00 - 11:00"
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Erreur réservation API: $e");
      return false;
    }
  }

  // ✅ MISE À JOUR : Vérifie si un créneau précis est libre
  Future<bool> verifierDisponibilite(
      int salleId, DateTime date, String creneau) async {
    final formattedDate =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    final url = Uri.parse(
        "$baseUrl/reservations/disponible?salleId=$salleId&date=$formattedDate&creneau=$creneau");

    try {
      final response = await http.get(url);
      return response.statusCode == 200 && response.body == "true";
    } catch (e) {
      return false;
    }
  }

  Future<List<Reservation>> getReservationsUtilisateur(String email) async {
    try {
      final response =
          await http.get(Uri.parse("$baseUrl/reservations/user/$email"));
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((r) => Reservation.fromJson(r)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> annulerReservation(int id) async {
    await http.delete(Uri.parse("$baseUrl/reservations/$id"));
  }

  // ------------------ ADMIN & STATS ------------------

  Future<List<Utilisateur>> getAllUtilisateurs() async {
    final response = await http.get(Uri.parse("$baseUrl/utilisateurs"));
    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((item) => Utilisateur.fromJson(item)).toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> getStats() async {
    try {
      final res =
          await http.get(Uri.parse("$baseUrl/stats")); // Ou l'URL de tes stats
      if (res.statusCode == 200) return json.decode(res.body);
    } catch (e) {
      print("Erreur stats: $e");
    }
    // Retour par défaut pour éviter le crash
    return {"utilisateurs": 0, "salles": 0, "reservations": 0};
  }

  Future<Salle> getSalleById(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/salles/$id"));
    if (response.statusCode == 200) {
      return Salle.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Erreur récupération salle");
    }
  }

  Future<List<Reservation>> getAllReservations() async {
    final response = await http.get(Uri.parse("$baseUrl/reservations/all"));
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((item) => Reservation.fromJson(item)).toList();
    }
    return [];
  }

  // ------------------ MESSAGES ------------------

  Future<bool> broadcastMessage(String titre, String contenu) async {
    final response = await http.post(
      Uri.parse('$baseUrl/messages/broadcast'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'titre': titre, 'contenu': contenu}),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<List<dynamic>> fetchMessages() async {
    final response = await http.get(Uri.parse('$baseUrl/messages/all'));
    return response.statusCode == 200 ? jsonDecode(response.body) : [];
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

//--------------------Mot de passe ---------------------
  Future<Map<String, dynamic>> modifierMotDePasse(
      String email, String ancien, String nouveau) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/modifier-password'), // Ton URL Spring Boot
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": email,
          "ancienPassword": ancien,
          "nouveauPassword": nouveau,
        }),
      );

      // Spring Boot renvoie un objet JSON
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Erreur serveur : $e"};
    }
  }

  Future<List<String>> getOccupiedSlots(int salleId, DateTime date) async {
    try {
      // On formate la date en yyyy-MM-dd pour que Spring Boot la comprenne bien
      String formattedDate =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      final response = await http.get(
        Uri.parse(
            '$baseUrl/reservations/occupations?salleId=$salleId&date=$formattedDate'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        // On transforme la liste dynamique en liste de String
        return data.map((slot) => slot.toString()).toList();
      } else {
        return []; // Retourne une liste vide si erreur
      }
    } catch (e) {
      debugPrint("Erreur getOccupiedSlots: $e");
      return [];
    }
  }
}
