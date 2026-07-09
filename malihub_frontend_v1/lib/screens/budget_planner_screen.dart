import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/stat_tile.dart';
import '../widgets/ring_progress.dart';

/// Budget Planner screen.
///
/// NOTE: monthly budget / spending / savings figures are mock data for now.
/// TODO: replace with live data from GET /api/budgets (current month) and
/// wire the "Monthly Budget" and "Target Amount" fields to
/// PUT /api/budgets/:id once the backend endpoints are ready.
///
/// The category budgets list below assumes a budget can have many category
/// allocations — that's the open design question on budget-category
/// cardinality (one category vs. a join table). This UI works either way,
/// but confirm with the backend/database team before wiring it up for real.
class BudgetPlannerScreen extends StatefulWidget {
  const BudgetPlannerScreen({super.key});

  @override
  State<BudgetPlannerScreen> createState() => _BudgetPlannerScreenState();
}

class _BudgetPlannerScreenState extends State<BudgetPlannerScreen> {
  final _budgetController = TextEditingController(text: '80000');
  final _targetController = TextEditingController(text: '20000');

  static const double monthlyBudget = 80000;
  static const double currentSpending = 24650;
  static const double savingsSaved = 52350;

  final List<Map<String, Object>> _categoryBudgets = const [
    {'name': 'Groceries', 'spent': 6800.0, 'budget': 8000.0},
    {'name': 'Transport', 'spent': 4450.0, 'budget': 4000.0},
    {'name': 'Rent', 'spent': 19000.0, 'budget': 19000.0},
    {'name': 'Entertainment', 'spent': 1200.0, 'budget': 3000.0},
  ];

  @override
  void dispose() {
    _budgetController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const remaining = monthlyBudget - currentSpending;
    final usedFraction =
        (currentSpending / monthlyBudget).clamp(0.0, 1.0).toDouble();
    final target = double.tryParse(_targetController.text) ?? 20000;
    final savingsFraction = (savingsSaved / target).clamp(0.0, 1.0).toDouble();

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
                    Text('Budget Planner',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('June 2026',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppShadows.subtle),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Monthly Budget',
                              style: AppText.sectionTitle),
                          const SizedBox(height: 14),
                          const Text('MONTHLY BUDGET (KES)',
                              style: AppText.eyebrow),
                          const SizedBox(height: 6),
                          TextField(
                              controller: _budgetController,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                              style: AppText.body),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Spending overview — ring takes the place of a flat bar.
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppShadows.subtle),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Spending Overview',
                              style: AppText.sectionTitle),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              RingProgress(
                                progress: usedFraction,
                                size: 72,
                                strokeWidth: 9,
                                color: AppColors.primary,
                                center: Text('${(usedFraction * 100).round()}%',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  "You've used ${(usedFraction * 100).round()}% of this month's budget.",
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                      height: 1.4),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                  child: StatTile(
                                      label: 'Monthly Budget',
                                      value:
                                          'KES ${monthlyBudget.toStringAsFixed(0)}',
                                      valueColor: AppColors.primary)),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: StatTile(
                                      label: 'Current Spending',
                                      value:
                                          'KES ${currentSpending.toStringAsFixed(0)}',
                                      valueColor: AppColors.expense)),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: StatTile(
                                      label: 'Remaining',
                                      value:
                                          'KES ${remaining.toStringAsFixed(0)}',
                                      valueColor: AppColors.primary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Category budgets — new section.
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppShadows.subtle),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Category Budgets',
                              style: AppText.sectionTitle),
                          const SizedBox(height: 14),
                          ..._categoryBudgets.map((c) {
                            final spent = c['spent'] as double;
                            final budget = c['budget'] as double;
                            final over = spent > budget;
                            final fraction =
                                (spent / budget).clamp(0.0, 1.0).toDouble();
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(c['name'] as String,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary)),
                                      Text(
                                        'KES ${spent.toStringAsFixed(0)} / ${budget.toStringAsFixed(0)}',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: over
                                                ? AppColors.expense
                                                : AppColors.textSecondary,
                                            fontWeight: over
                                                ? FontWeight.w600
                                                : FontWeight.w400),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: LinearProgressIndicator(
                                      value: fraction,
                                      minHeight: 7,
                                      backgroundColor: AppColors.surfaceSunken,
                                      valueColor: AlwaysStoppedAnimation(over
                                          ? AppColors.expense
                                          : AppColors.primary),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Savings goal — gold ring, ties visually to the Dashboard.
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppShadows.subtle),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                    color: AppColors.goldPale,
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.emoji_events_rounded,
                                    size: 16, color: AppColors.goldDeep),
                              ),
                              const SizedBox(width: 8),
                              const Text('Savings Goal',
                                  style: AppText.sectionTitle),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Text('TARGET AMOUNT (KES)',
                              style: AppText.eyebrow),
                          const SizedBox(height: 6),
                          TextField(
                              controller: _targetController,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                              style: AppText.body),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              RingProgress(
                                progress: savingsFraction,
                                size: 56,
                                strokeWidth: 7,
                                color: AppColors.gold,
                                trackColor: AppColors.goldPale,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('KES 52,350 saved',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.goldDeep,
                                            fontWeight: FontWeight.w600)),
                                    Text(
                                        '${(savingsFraction * 100).round()}% of KES ${target.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                            ],
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
