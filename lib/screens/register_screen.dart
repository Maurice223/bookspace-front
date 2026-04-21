import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();

  // Contrôleurs
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController nomController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool _isPasswordVisible = false;

  // Design Colors
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
    prenomController.dispose();
    nomController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    // On récupère la map au lieu du simple code
    final result = await apiService.register(
      prenomController.text.trim(),
      nomController.text.trim(),
      emailController.text.trim(),
      passwordController.text.trim(),
      usernameController.text.trim(),
      phoneController.text.trim(),
    );

    setState(() => isLoading = false);

    int statusCode = result["status"];
    String serverMessage = result["message"];

    if (statusCode == 201) {
      _showCustomSnackBar("✅ Inscription réussie !", isError: false);
      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    } else {
      // 💡 Ici, on affiche le message précis envoyé par Spring Boot
      // Que ce soit le téléphone, l'email ou le pseudo, c'est dynamique !
      _showCustomSnackBar("❌ $serverMessage", isError: true);
    }
  }

  void _showCustomSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor:
            isError ? Colors.redAccent.withOpacity(0.9) : primaryTurquoise,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          _buildBlurCircle(300, primaryTurquoise.withOpacity(0.15),
              top: -100, right: -50),
          _buildBlurCircle(250, Colors.blueAccent.withOpacity(0.1),
              bottom: -50, left: -50),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 20),
                    child: Column(
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 30),
                        _buildGlassForm(),
                        const SizedBox(height: 25),
                        _buildFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Text("BookSpace",
            style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.5)),
        Text("Rejoignez l'aventure",
            style:
                TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16)),
      ],
    );
  }

  Widget _buildGlassForm() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: glassBg,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: _buildTextField(
                            controller: prenomController,
                            hint: "Prénom",
                            icon: Icons.person_outline)),
                    const SizedBox(width: 15),
                    Expanded(
                        child: _buildTextField(
                            controller: nomController,
                            hint: "Nom",
                            icon: Icons.badge_outlined)),
                  ],
                ),
                const SizedBox(height: 15),
                _buildTextField(
                    controller: usernameController,
                    hint: "Nom d'utilisateur",
                    icon: Icons.alternate_email),
                const SizedBox(height: 15),
                _buildTextField(
                    controller: emailController,
                    hint: "E-mail",
                    icon: Icons.email_outlined,
                    type: TextInputType.emailAddress),
                const SizedBox(height: 15),

                // ✅ TÉLÉPHONE (8-12 chiffres)
                _buildTextField(
                    controller: phoneController,
                    hint: "Téléphone",
                    icon: Icons.phone_android_outlined,
                    isPhone: true),

                const SizedBox(height: 15),

                // ✅ MOT DE PASSE (Min 8 car + 1 Lettre + 1 Chiffre)
                _buildTextField(
                    controller: passwordController,
                    hint: "Mot de passe",
                    icon: Icons.lock_outline,
                    isPassword: true,
                    isPasswordField: true),

                const SizedBox(height: 30),
                _buildRegisterButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isPhone = false,
    bool isPasswordField = false,
    TextInputType type = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? !_isPasswordVisible : false,
      keyboardType: isPhone ? TextInputType.number : type,
      inputFormatters: isPhone
          ? [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(12)
            ]
          : null,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 14),
        prefixIcon: Icon(icon, color: primaryTurquoise, size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.white30),
                onPressed: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
              )
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.white10)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: primaryTurquoise)),
        errorStyle: const TextStyle(color: Colors.orangeAccent),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return "Champ requis";
        if (isPhone) {
          if (v.length < 8) return "Min. 8 chiffres";
          if (v.length > 12) return "Max. 12 chiffres";
        }
        if (isPasswordField) {
          if (v.length < 8) return "Min. 8 caractères";
          if (!v.contains(RegExp(r'[0-9]'))) return "Ajoutez un chiffre";
          if (!v.contains(RegExp(r'[a-zA-Z]'))) return "Ajoutez une lettre";
        }
        return null;
      },
    );
  }

  Widget _buildRegisterButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: primaryTurquoise.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6))
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : register,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTurquoise,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : const Text("CRÉER MON COMPTE",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Widget _buildFooter() {
    return TextButton(
      onPressed: () => Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginScreen())),
      child: RichText(
        text: TextSpan(
          text: "Déjà un membre ? ",
          style: TextStyle(color: Colors.white.withOpacity(0.5)),
          children: [
            TextSpan(
                text: "Se connecter",
                style: TextStyle(
                    color: primaryTurquoise, fontWeight: FontWeight.bold))
          ],
        ),
      ),
    );
  }

  Widget _buildBlurCircle(double size, Color color,
      {double? top, double? bottom, double? left, double? right}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
            child: Container(color: Colors.transparent)),
      ),
    );
  }
}
