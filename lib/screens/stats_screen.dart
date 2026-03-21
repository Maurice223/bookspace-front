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

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    loadStats();
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
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur chargement statistiques")));
    }
  }

  Widget statCard(String title, int value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withOpacity(0.8), color]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 35, color: Colors.white),
          const SizedBox(height: 10),
          Text(
            value.toString(),
            style: const TextStyle(
                fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(title,
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }

  Widget pieChart() {
    final total = usersCount + sallesCount + reservationsCount;
    if (total == 0)
      return const Center(
          child: Text("Pas de données", style: TextStyle(color: Colors.white)));

    return PieChart(
      PieChartData(
        sectionsSpace: 3,
        centerSpaceRadius: 40,
        sections: [
          PieChartSectionData(
            value: usersCount.toDouble(),
            color: Colors.blue,
            title: 'Users\n$usersCount',
            radius: 60,
            titleStyle: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          PieChartSectionData(
            value: sallesCount.toDouble(),
            color: Colors.green,
            title: 'Salles\n$sallesCount',
            radius: 60,
            titleStyle: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          PieChartSectionData(
            value: reservationsCount.toDouble(),
            color: Colors.orange,
            title: 'Réservations\n$reservationsCount',
            radius: 60,
            titleStyle: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget barChart() {
    final maxY = [
          usersCount.toDouble(),
          sallesCount.toDouble(),
          reservationsCount.toDouble()
        ].reduce((a, b) => a > b ? a : b) +
        5;

    return BarChart(
      BarChartData(
        maxY: maxY,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            horizontalInterval: 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(color: Colors.white12, strokeWidth: 1);
            }),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                interval: 5,
                reservedSize: 30,
                getTitlesWidget: (v, meta) => Text(v.toInt().toString(),
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 10))),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, meta) {
                  switch (v.toInt()) {
                    case 0:
                      return const Text("Users",
                          style: TextStyle(color: Colors.white));
                    case 1:
                      return const Text("Salles",
                          style: TextStyle(color: Colors.white));
                    case 2:
                      return const Text("Res",
                          style: TextStyle(color: Colors.white));
                  }
                  return const Text("");
                }),
          ),
        ),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: usersCount.toDouble() * _animation.value,
                width: 25,
                gradient: const LinearGradient(
                    colors: [Colors.blue, Colors.lightBlueAccent]),
                borderRadius: BorderRadius.circular(6),
                backDrawRodData: BackgroundBarChartRodData(
                    show: true, fromY: 0, toY: maxY, color: Colors.white12),
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: sallesCount.toDouble() * _animation.value,
                width: 25,
                gradient: const LinearGradient(
                    colors: [Colors.green, Colors.lightGreenAccent]),
                borderRadius: BorderRadius.circular(6),
                backDrawRodData: BackgroundBarChartRodData(
                    show: true, fromY: 0, toY: maxY, color: Colors.white12),
              ),
            ],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [
              BarChartRodData(
                toY: reservationsCount.toDouble() * _animation.value,
                width: 25,
                gradient: const LinearGradient(
                    colors: [Colors.orange, Colors.deepOrangeAccent]),
                borderRadius: BorderRadius.circular(6),
                backDrawRodData: BackgroundBarChartRodData(
                    show: true, fromY: 0, toY: maxY, color: Colors.white12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistiques"),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        iconTheme: IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient:
                LinearGradient(colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)]),
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient:
              LinearGradient(colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)]),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ✅ CARDS STATS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: statCard("Utilisateurs", usersCount,
                                Colors.blue, Icons.people)),
                        const SizedBox(width: 15),
                        Expanded(
                            child: statCard("Salles", sallesCount, Colors.green,
                                Icons.meeting_room)),
                        const SizedBox(width: 15),
                        Expanded(
                            child: statCard("Réservations", reservationsCount,
                                Colors.orange, Icons.book_online)),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // ✅ PIE CHART
                    Container(
                      height: 250,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: pieChart(),
                    ),
                    const SizedBox(height: 30),

                    // ✅ BAR CHART
                    Container(
                      height: 250,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: barChart(),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
