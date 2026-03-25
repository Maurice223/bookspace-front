import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/utilisateur.dart';
import '../models/salle.dart';
import '../models/reservation.dart';

class ApiService {
  final String baseUrl = "https://backend-b.up.railway.app";

  // ------------------ UTILISATEUR ------------------

  Future<int> register(
      String prenom, String nom, String email, String password) async {
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
        }),
      );
      return response.statusCode;
    } catch (e) {
      print("Erreur register: $e");
      return 0;
    }
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/utilisateurs/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Erreur login: $e");
    }
    return null;
  }

  Future<Utilisateur?> getUtilisateur(String email) async {
    final response = await http.get(Uri.parse('$baseUrl/utilisateurs/$email'));
    if (response.statusCode == 200) {
      return Utilisateur.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  /// ------------------ SUPPRIMER UTILISATEUR ------------------
  Future<bool> deleteUser(int id) async {
    final response =
        await http.delete(Uri.parse('$baseUrl/utilisateurs/delete/$id'));

    return response.statusCode == 200 || response.statusCode == 204;
  }

  /// ------------------ STATS ------------------
  Future<Map<String, dynamic>> getStats() async {
    final res = await http.get(Uri.parse("$baseUrl/stats"));
    if (res.statusCode == 200) {
      return json.decode(res.body);
    } else {
      throw Exception("Erreur stats");
    }
  }

  Future<int> getUsersCount() async {
    final response = await http.get(Uri.parse("$baseUrl/utilisateurs/count"));
    return int.tryParse(response.body) ?? 0;
  }

  Future<List<dynamic>> fetchUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/utilisateurs'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur récupération utilisateurs');
    }
  }

  // ------------------ SALLE ------------------

  Future<List<Salle>> getAllSalles() async {
    final response = await http.get(Uri.parse("$baseUrl/salles"));
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map<Salle>((e) => Salle.fromJson(e)).toList();
    } else {
      throw Exception("Erreur chargement salles");
    }
  }

  Future<Salle> getSalleById(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/salles/$id"));
    if (response.statusCode == 200) {
      return Salle.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Erreur récupération salle");
    }
  }

  Future<bool> addSalle(
      String nom, int capacite, String image, String description) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/salles"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nom": nom,
          "capacite": capacite,
          "image": image,
          "description": description,
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Erreur addSalle: $e");
      return false;
    }
  }

  Future<bool> deleteSalle(int id) async {
    final response = await http.delete(
      Uri.parse(
          "$baseUrl/salles/delete/$id"), // <-- ici correspond au DeleteMapping
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }

  // ------------------ RÉSERVATION ------------------

  Future<bool> reserverSalleAvecDate(
      int salleId, String email, DateTime date) async {
    final formattedDate =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final url = Uri.parse(
        "$baseUrl/reservations/reserver?salleId=$salleId&utilisateurEmail=$email&date=$formattedDate");
    final response = await http.post(url);
    return response.statusCode == 200;
  }

  Future<bool> verifierDisponibilite(int salleId, DateTime date) async {
    final formattedDate =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final url = Uri.parse(
        "$baseUrl/reservations/disponible?salleId=$salleId&date=$formattedDate");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return response.body == "true";
    } else {
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
      } else {
        throw Exception("Erreur chargement réservations");
      }
    } catch (e) {
      print("Erreur reservations: $e");
      return [];
    }
  }

  Future<void> annulerReservation(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/reservations/$id"));
    if (response.statusCode != 200) {
      throw Exception("Erreur suppression réservation");
    }
  }

  Future<List<Reservation>> fetchReservations() async {
    final response = await http.get(Uri.parse('$baseUrl/reservations/all'));

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((r) => Reservation.fromJson(r)).toList();
    } else {
      throw Exception("Erreur chargement réservations");
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}
