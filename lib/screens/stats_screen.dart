import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  int usersCount = 0;
  int sallesCount = 0;
  int reservationsCount = 0;
  bool isLoading = true;

  late AnimationController _controller;
  late Animation<double> _animation;

  // ✅ Palette BookSpace (Identique au Login)
  final Color primaryTurquoise = const Color(0xFF26A69A);
  final Color darkBg = const Color(0xFF0F172A);
  final Color glassBg = Colors.white.withOpacity(0.08);

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    loadStats();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> loadStats() async {
    setState(() => isLoading = true);
    try {
      final stats = await ApiService().getStats();
      setState(() {
        usersCount = stats['users'] ?? 0;
        sallesCount = stats['salles'] ?? 0;
        reservationsCount = stats['reservations'] ?? 0;
        isLoading = false;
      });
      _controller.forward();
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorSnackBar("Erreur de synchronisation des données");
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Tableau de Bord",
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // ✅ 1. Arrière-plan avec Cercles Lumineux (Comme au Login)
          Positioned(
              top: -50,
              right: -50,
              child: _buildBlurCircle(250, primaryTurquoise.withOpacity(0.15))),
          Positioned(
              bottom: 100,
              left: -50,
              child: _buildBlurCircle(200, Colors.blueAccent.withOpacity(0.1))),

          isLoading
              ? Center(
                  child: CircularProgressIndicator(color: primaryTurquoise))
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 120, 20, 20),
                  child: Column(
                    children: [
                      // ✅ 2. Cartes de Statistiques Glassmorphism
                      Row(
                        children: [
                          Expanded(
                              child: _buildStatCard("Users", usersCount,
                                  Colors.blueAccent, Icons.people_rounded)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _buildStatCard(
                                  "Salles",
                                  sallesCount,
                                  primaryTurquoise,
                                  Icons.meeting_room_rounded)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _buildStatCard(
                                  "Résas",
                                  reservationsCount,
                                  Colors.orangeAccent,
                                  Icons.event_available_rounded)),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // ✅ 3. Graphique Circulaire (Pie Chart)
                      _buildSectionTitle("Répartition des Ressources"),
                      _buildGlassContainer(
                          height: 280, child: _buildPieChart()),

                      const SizedBox(height: 30),

                      // ✅ 4. Graphique en Barres (Bar Chart)
                      _buildSectionTitle("Analyse Comparative"),
                      _buildGlassContainer(
                          height: 280, child: _buildBarChart()),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  // --- COMPOSANTS DESIGN ---

  Widget _buildBlurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
          child: Container(color: Colors.transparent)),
    );
  }

  Widget _buildStatCard(
      String title, int value, Color iconColor, IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: glassBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              Icon(icon, size: 26, color: iconColor),
              const SizedBox(height: 8),
              Text(value.toString(),
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              Text(title,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 5),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title,
            style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildGlassContainer({required double height, required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: height,
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: glassBg,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: child,
        ),
      ),
    );
  }

  // --- LOGIQUE DES CHARTS ---

  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sectionsSpace: 5,
        centerSpaceRadius: 50,
        sections: [
          PieChartSectionData(
              value: usersCount.toDouble(),
              color: Colors.blueAccent,
              title: '$usersCount',
              radius: 55,
              titleStyle: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          PieChartSectionData(
              value: sallesCount.toDouble(),
              color: primaryTurquoise,
              title: '$sallesCount',
              radius: 55,
              titleStyle: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          PieChartSectionData(
              value: reservationsCount.toDouble(),
              color: Colors.orangeAccent,
              title: '$reservationsCount',
              radius: 55,
              titleStyle: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
              sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (v, m) => Text(v.toInt().toString(),
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 10)))),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, m) {
                const style = TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold);
                if (v == 0) return const Text("Users", style: style);
                if (v == 1) return const Text("Salles", style: style);
                if (v == 2) return const Text("Resas", style: style);
                return const Text("");
              },
            ),
          ),
        ),
        barGroups: [
          _makeGroupData(0, usersCount.toDouble(), Colors.blueAccent),
          _makeGroupData(1, sallesCount.toDouble(), primaryTurquoise),
          _makeGroupData(2, reservationsCount.toDouble(), Colors.orangeAccent),
        ],
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y * _animation.value,
          color: color,
          width: 22,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          backDrawRodData: BackgroundBarChartRodData(
              show: true, toY: (y + 5), color: Colors.white.withOpacity(0.05)),
        ),
      ],
    );
  }
}
