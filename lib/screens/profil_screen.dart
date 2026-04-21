import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/utilisateur.dart';
import '../services/api_service.dart';
// ✅ Assure-toi que ce chemin correspond bien à l'emplacement de ton fichier login
import 'login_screen.dart';

class ProfilScreen extends StatefulWidget {
  final String utilisateurEmail;

  const ProfilScreen({super.key, required this.utilisateurEmail});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen>
    with SingleTickerProviderStateMixin {
  final ApiService apiService = ApiService();

  final Color primaryTurquoise = const Color(0xFF26A69A);
  final Color darkBg = const Color(0xFF0F172A);

  bool isLoading = false;
  Utilisateur? utilisateur;

  @override
  void initState() {
    super.initState();
    _loadUtilisateur();
  }

  Future<void> _loadUtilisateur() async {
    setState(() => isLoading = true);
    utilisateur = await apiService.getUtilisateur(widget.utilisateurEmail);
    if (mounted) setState(() => isLoading = false);
  }

  // ✅ FONCTION DE DÉCONNEXION ACTIVÉE
  void _handleLogout() {
    // Navigator.pushAndRemoveUntil permet de fermer toutes les pages
    // et de mettre la page Login comme seule page ouverte.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  void _showComingSoonMessage(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.construction_rounded,
                color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "L'option '$feature' est en cours de développement 🚀",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: primaryTurquoise.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryTurquoise))
          : utilisateur == null
              ? _buildErrorState()
              : Stack(
                  children: [
                    Positioned(
                      top: -100,
                      right: -50,
                      child: _buildBlurCircle(
                          300, primaryTurquoise.withOpacity(0.15)),
                    ),
                    CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Container(
                            padding: const EdgeInsets.only(top: 60, bottom: 30),
                            child: Column(
                              children: [
                                _buildPremiumAvatar(),
                                const SizedBox(height: 20),
                                Text(
                                  "${utilisateur!.prenom} ${utilisateur!.nom}",
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "@${utilisateur!.nomUtilisateur}",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: primaryTurquoise,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.2),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              const Text(
                                "Informations du compte",
                                style: TextStyle(
                                    color: Colors.white38,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    letterSpacing: 1),
                              ),
                              const SizedBox(height: 15),
                              _buildGlassInfoTile(
                                  "Nom d'utilisateur",
                                  utilisateur!.nomUtilisateur,
                                  Icons.alternate_email_rounded),
                              _buildGlassInfoTile("Email", utilisateur!.email,
                                  Icons.mail_outline_rounded),
                              _buildGlassInfoTile(
                                  "Téléphone",
                                  utilisateur!.telephone ?? "Non renseigné",
                                  Icons.phone_android_rounded),

                              const SizedBox(height: 35),
                              const Text(
                                "Réglages & Sécurité",
                                style: TextStyle(
                                    color: Colors.white38,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    letterSpacing: 1),
                              ),
                              const SizedBox(height: 10),
                              _buildActionRow(
                                  Icons.lock_reset_rounded,
                                  "Changer le mot de passe",
                                  () => _showComingSoonMessage("Mot de passe")),
                              _buildActionRow(
                                  Icons.language_rounded,
                                  "Langue de l'application",
                                  () => _showComingSoonMessage("Langues")),

                              const SizedBox(height: 25),
                              const Text(
                                "Session",
                                style: TextStyle(
                                    color: Colors.white38,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    letterSpacing: 1),
                              ),
                              const SizedBox(height: 10),

                              // ✅ BOUTON DÉCONNEXION APPELANT _handleLogout
                              _buildActionRow(Icons.logout_rounded,
                                  "Se déconnecter", _handleLogout,
                                  isDestructive: true),

                              const SizedBox(height: 100),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
    );
  }

  Widget _buildPremiumAvatar() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [primaryTurquoise, Colors.blueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: CircleAvatar(
        radius: 65,
        backgroundColor: darkBg,
        child: Text(
          utilisateur!.nom[0].toUpperCase(),
          style: const TextStyle(
              fontSize: 50, fontWeight: FontWeight.w900, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildGlassInfoTile(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withOpacity(0.03),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(icon, color: primaryTurquoise, size: 22),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(value,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionRow(IconData icon, String title, VoidCallback onTap,
      {bool isDestructive = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        child: Row(
          children: [
            Icon(icon,
                color: isDestructive
                    ? Colors.redAccent.withOpacity(0.8)
                    : Colors.white38,
                size: 22),
            const SizedBox(width: 15),
            Text(title,
                style: TextStyle(
                    color: isDestructive ? Colors.redAccent : Colors.white70,
                    fontSize: 15,
                    fontWeight:
                        isDestructive ? FontWeight.bold : FontWeight.normal)),
            const Spacer(),
            if (!isDestructive)
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white12, size: 14),
          ],
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

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
          const SizedBox(height: 10),
          const Text("Profil introuvable",
              style: TextStyle(color: Colors.white70)),
          TextButton(
              onPressed: _loadUtilisateur,
              child:
                  Text("Réessayer", style: TextStyle(color: primaryTurquoise))),
        ],
      ),
    );
  }
}
