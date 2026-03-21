import 'package:flutter/material.dart';
import '../models/utilisateur.dart';
import '../services/api_service.dart';

class ProfilScreen extends StatefulWidget {
  final String utilisateurEmail;

  const ProfilScreen({super.key, required this.utilisateurEmail});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen>
    with SingleTickerProviderStateMixin {
  final ApiService apiService = ApiService();

  bool isLoading = false;
  Utilisateur? utilisateur;

  late ScrollController _scrollController;
  double _avatarScale = 1.0;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadUtilisateur();

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Animations douces
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
            .animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  void _onScroll() {
    double offset = _scrollController.offset;
    setState(() {
      _avatarScale = 1 - (offset / 500).clamp(0.0, 0.2);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUtilisateur() async {
    setState(() => isLoading = true);
    utilisateur = await apiService.getUtilisateur(widget.utilisateurEmail);
    setState(() => isLoading = false);
  }

  Color getColorFromName(String name) {
    final colors = [
      Colors.indigo,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
    ];
    return colors[name.length % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : utilisateur == null
              ? const Center(child: Text("Erreur lors du chargement"))
              : Stack(
                  children: [
                    // Background gradient subtil
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xff6a11cb), Color(0xff2575fc)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    SafeArea(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Avatar premium
                                Transform.scale(
                                  scale: _avatarScale,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          getColorFromName(utilisateur!.nom),
                                          getColorFromName(utilisateur!.prenom)
                                              .withOpacity(0.7)
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: CircleAvatar(
                                      radius: 60,
                                      backgroundColor: Colors.white,
                                      child: Text(
                                        utilisateur!.nom[0].toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 42,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  "${utilisateur!.prenom} ${utilisateur!.nom}",
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  utilisateur!.email,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 40),

                                // Info Cards
                                _infoCard("Prénom", utilisateur!.prenom),
                                const SizedBox(height: 15),
                                _infoCard("Nom", utilisateur!.nom),
                                const SizedBox(height: 15),
                                _infoCard("Email", utilisateur!.email),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _infoCard(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.black26.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.grey[800], fontWeight: FontWeight.w500)),
          const SizedBox(height: 5),
          Text(value,
              style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
