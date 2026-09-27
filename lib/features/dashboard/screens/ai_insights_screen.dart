import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';

class AiInsightsScreen extends StatelessWidget {
  const AiInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Health Insights", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. SUMMARY CARD
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 24),
                      SizedBox(width: 12),
                      Text(
                        "Weekly Summary",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Your overall safety score has improved by 4% since last week. Medication adherence is at 98%, and your nighttime activity is normal.",
                    style: TextStyle(color: Colors.white, fontSize: 14, height: 1.5, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 2. ACTIVITY CHART
            const Text(
              "Response Time Trend",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            Container(
              height: 220,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
              ),
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 3),
                        FlSpot(1, 1),
                        FlSpot(2, 4),
                        FlSpot(3, 2),
                        FlSpot(4, 5),
                        FlSpot(5, 3),
                        FlSpot(6, 4),
                      ],
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 4,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 3. DRILL-DOWN CATEGORIES
            const Text(
              "Detailed Analysis",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            const _InsightDrillDown(
              icon: Icons.speed_rounded,
              title: "Reaction Speed",
              value: "Average 1.2s",
              trend: "+15%",
              isPositive: true,
            ),
            const _InsightDrillDown(
              icon: Icons.nightlight_round,
              title: "Sleep Quality",
              value: "7h 45m avg",
              trend: "-2%",
              isPositive: false,
            ),
            const _InsightDrillDown(
              icon: Icons.medication_rounded,
              title: "Adherence",
              value: "98% compliance",
              trend: "+1.5%",
              isPositive: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightDrillDown extends StatelessWidget {
  const _InsightDrillDown({
    required this.icon,
    required this.title,
    required this.value,
    required this.trend,
    required this.isPositive,
  });

  final IconData icon;
  final String title;
  final String value;
  final String trend;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                Text(value, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                trend,
                style: TextStyle(
                  color: isPositive ? AppColors.secondary : AppColors.error,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Text("this week", style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
