import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/donut_chart.dart';

/// Analytics / Insights screen — new addition beyond the original
/// wireframes. Gives a spending breakdown by category and a plain
/// month-over-month comparison, both built from hand-drawn charts rather
/// than a generic chart package.
///
/// TODO: replace mock category totals with an aggregation endpoint, e.g.
/// GET /api/transactions/summary?month=2026-06, grouped by category.
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final slices = [
      DonutSlice(label: 'Rent', value: 19000, color: AppColors.primaryDeep),
      DonutSlice(label: 'Groceries', value: 6800, color: AppColors.primary),
      DonutSlice(label: 'Transport', value: 4450, color: AppColors.gold),
      DonutSlice(label: 'Entertainment', value: 1200, color: AppColors.expense),
    ];
    final total = slices.fold<double>(0, (sum, s) => sum + s.value);

    const thisMonth = 24650.0;
    const lastMonth = 28000.0;
    const maxVal = thisMonth > lastMonth ? thisMonth : lastMonth;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Insights',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Where your money went in June',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Spending by category — donut
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppShadows.subtle),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Spending by Category',
                              style: AppText.sectionTitle),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              DonutChart(
                                  slices: slices, size: 140, strokeWidth: 20),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: slices.map((s) {
                                    final pct = total == 0
                                        ? 0
                                        : (s.value / total * 100).round();
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Row(
                                        children: [
                                          Container(
                                              width: 10,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                  color: s.color,
                                                  shape: BoxShape.circle)),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(s.label,
                                                style: const TextStyle(
                                                    fontSize: 12.5,
                                                    color:
                                                        AppColors.textPrimary),
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ),
                                          Text('$pct%',
                                              style: const TextStyle(
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      AppColors.textSecondary)),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // This month vs last month
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppShadows.subtle),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('This Month vs Last Month',
                              style: AppText.sectionTitle),
                          const SizedBox(height: 20),
                          const Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: _ComparisonBar(
                                  label: 'Last month',
                                  value: lastMonth,
                                  maxValue: maxVal,
                                  color: AppColors.surfaceSunken,
                                  textColor: AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: _ComparisonBar(
                                  label: 'This month',
                                  value: thisMonth,
                                  maxValue: maxVal,
                                  color: AppColors.primary,
                                  textColor: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: AppColors.goldPale,
                                borderRadius: BorderRadius.circular(12)),
                            child: const Row(
                              children: [
                                Icon(Icons.trending_down_rounded,
                                    color: AppColors.goldDeep, size: 18),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text('12% less spent than last month',
                                      style: TextStyle(
                                          fontSize: 12.5,
                                          color: AppColors.goldDeep,
                                          fontWeight: FontWeight.w500)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComparisonBar extends StatelessWidget {
  final String label;
  final double value;
  final double maxValue;
  final Color color;
  final Color textColor;

  const _ComparisonBar(
      {required this.label,
      required this.value,
      required this.maxValue,
      required this.color,
      required this.textColor});

  @override
  Widget build(BuildContext context) {
    final height = maxValue == 0 ? 0.0 : (value / maxValue) * 100;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('KES ${value.toStringAsFixed(0)}',
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700, color: textColor)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: height.clamp(8, 100).toDouble(),
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(label,
            style:
                const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}
