import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_admin_screen.dart';
import 'home_user_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();

  // ✅ Changement : emailController -> usernameController
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  final Color primaryTurquoise = const Color(0xFF26A69A);
  final Color darkBg = const Color(0xFF0F172A);
  final Color glassBg = Colors.white.withOpacity(0.1);

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    _fadeAnimation =
        CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    usernameController.dispose(); // ✅
    passwordController.dispose();
    super.dispose();
  }

  void login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    // ✅ Envoi du nom d'utilisateur au service
    var user = await apiService.login(
        usernameController.text.trim(), passwordController.text.trim());

    setState(() => isLoading = false);

    if (user != null) {
      if (user['role'] == 'ADMIN') {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const HomeAdminScreen()));
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => HomeUserScreen(
                    utilisateurEmail:
                        user['nomUtilisateur']))); // ✅ On passe le pseudo
      }
    } else {
      _showCustomSnackBar("Nom d'utilisateur ou mot de passe incorrect",
          isError: true);
    }
  }

  void _showCustomSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(message, style: const TextStyle(fontWeight: FontWeight.w500)),
        backgroundColor: isError
            ? Colors.redAccent.withOpacity(0.9)
            : primaryTurquoise.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          Positioned(
              top: -100,
              left: -50,
              child: _buildBlurCircle(300, primaryTurquoise.withOpacity(0.2))),
          Positioned(
              bottom: -50,
              right: -50,
              child:
                  _buildBlurCircle(250, Colors.blueAccent.withOpacity(0.15))),
          FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 35),
                      _buildGlassForm(),
                      const SizedBox(height: 25),
                      _buildFooter(),
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

  Widget _buildBlurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              Colors.white,
              primaryTurquoise.withOpacity(0.7),
              primaryTurquoise
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text("BookSpace",
              style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  color: Colors.white)),
        ),
        const SizedBox(height: 15),
        const Text("Bienvenue",
            style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text(
          "Connectez-vous avec votre pseudo.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildGlassForm() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: glassBg,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // ✅ Changé : Nom d'utilisateur au lieu d'Email
                _buildTextField(
                    controller: usernameController,
                    hint: "Nom d'utilisateur",
                    icon: Icons.alternate_email),
                const SizedBox(height: 20),
                _buildTextField(
                    controller: passwordController,
                    hint: "Mot de passe",
                    icon: Icons.lock_outline,
                    isPassword: true),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _rememberMe = !_rememberMe),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: _rememberMe,
                              onChanged: (v) =>
                                  setState(() => _rememberMe = v ?? false),
                              activeColor: primaryTurquoise,
                              side: const BorderSide(color: Colors.white30),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text("Se souvenir",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showCustomSnackBar(
                          "Récupération bientôt disponible..."),
                      child: Text("Oublié ?",
                          style:
                              TextStyle(color: primaryTurquoise, fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                _buildLoginButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: primaryTurquoise.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8))
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : login,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTurquoise,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : const Text("SE CONNECTER",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 1.2)),
      ),
    );
  }

  Widget _buildFooter() {
    return TextButton(
      onPressed: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
      child: RichText(
        text: TextSpan(
          text: "Pas encore de compte ? ",
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
          children: [
            TextSpan(
                text: "Inscrivez-vous",
                style: TextStyle(
                    color: primaryTurquoise, fontWeight: FontWeight.bold))
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String hint,
      required IconData icon,
      bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? !_isPasswordVisible : false,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 14),
        prefixIcon:
            Icon(icon, color: primaryTurquoise.withOpacity(0.7), size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.white.withOpacity(0.3),
                    size: 20),
                onPressed: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
              )
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.white10)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: primaryTurquoise.withOpacity(0.5))),
      ),
      validator: (v) => (v == null || v.isEmpty) ? "Champ requis" : null,
    );
  }
}
