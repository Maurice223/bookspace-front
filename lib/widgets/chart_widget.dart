import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartWidget extends StatelessWidget {
  final int users;
  final int salles;
  final int reservations;

  const ChartWidget({
    super.key,
    required this.users,
    required this.salles,
    required this.reservations,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(show: false),
          barGroups: [
            BarChartGroupData(x: 0, barRods: [
              BarChartRodData(toY: users.toDouble()),
            ]),
            BarChartGroupData(x: 1, barRods: [
              BarChartRodData(toY: salles.toDouble()),
            ]),
            BarChartGroupData(x: 2, barRods: [
              BarChartRodData(toY: reservations.toDouble()),
            ]),
          ],
        ),
      ),
    );
  }
}
