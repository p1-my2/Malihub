import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/stat_tile.dart';
import '../widgets/ring_progress.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';

/// Home / Dashboard screen.
///
/// NOTE: all figures below are placeholder/mock data matching the project's
/// data model. TODO: replace with a live GET /api/dashboard call once the
/// backend endpoint is available, and convert this to consume that response
/// (e.g. via a DashboardData model + FutureBuilder or state management).
class DashboardScreen extends StatelessWidget {
  final ValueChanged<int>? onNavigate;
  final VoidCallback? onLogout;

  const DashboardScreen({super.key, this.onNavigate, this.onLogout});

  @override
  Widget build(BuildContext context) {
    const userName = 'Amara Odhiambo';
    const initials = 'AO';
    const currentBalance = 'KES 52,350';
    const totalIncome = 'KES 77,000';
    const totalExpenses = 'KES 24,650';
    const savingsSaved = 52350;
    const savingsTarget = 20000;
    final savingsProgress =
        (savingsSaved / savingsTarget).clamp(0.0, 1.0).toDouble();

    final recentTransactions = [
      _TransactionMock(
          title: 'Salary',
          date: '1 Jun 2026',
          amount: '+KES 65,000',
          isIncome: true,
          icon: Icons.trending_up_rounded),
      _TransactionMock(
          title: 'Groceries',
          date: '3 Jun 2026',
          amount: '-KES 4,200',
          isIncome: false,
          icon: Icons.shopping_cart_outlined),
      _TransactionMock(
          title: 'Freelance Gig',
          date: '5 Jun 2026',
          amount: '+KES 12,000',
          isIncome: true,
          icon: Icons.trending_up_rounded),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Good morning 👋',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 13)),
                              SizedBox(height: 2),
                              Text(userName,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const NotificationsScreen())),
                          child: Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                shape: BoxShape.circle),
                            child: const Icon(Icons.notifications_none_rounded,
                                color: Colors.white, size: 20),
                          ),
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) =>
                                    ProfileScreen(onLogout: onLogout ?? () {})),
                          ),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.2),
                            child: const Text(initials,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(18)),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Current Balance',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                          SizedBox(height: 6),
                          Text(currentBalance,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('Updated just now',
                              style: TextStyle(
                                  color: Colors.white60, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),

                    // Insight card — new, unique to this build: a plain-language
                    // read on how this month compares to last, not just raw numbers.
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: AppColors.goldPale,
                          borderRadius: BorderRadius.circular(16)),
                      child: const Row(
                        children: [
                          Icon(Icons.auto_graph_rounded,
                              color: AppColors.goldDeep, size: 22),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "You've spent 12% less than last month. Keep it up.",
                              style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.goldDeep,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Row(
                      children: [
                        Expanded(
                          child: StatTile(
                            label: 'Total Income',
                            value: totalIncome,
                            valueColor: AppColors.income,
                            icon: Icons.trending_up_rounded,
                            iconBackground: AppColors.incomePale,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: StatTile(
                            label: 'Total Expenses',
                            value: totalExpenses,
                            valueColor: AppColors.expense,
                            icon: Icons.trending_down_rounded,
                            iconBackground: AppColors.expensePale,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Savings goal — uses the signature ring motif.
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppShadows.subtle),
                      child: Row(
                        children: [
                          RingProgress(
                            progress: savingsProgress,
                            size: 64,
                            strokeWidth: 8,
                            color: AppColors.gold,
                            trackColor: AppColors.goldPale,
                            center: Text('${(savingsProgress * 100).round()}%',
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.goldDeep)),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Savings Goal',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: AppColors.textPrimary)),
                                SizedBox(height: 4),
                                Text('KES 52,350 saved',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary)),
                                Text('Target: KES 20,000',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text('Quick Actions', style: AppText.sectionTitle),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => onNavigate?.call(1),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add Transaction'),
                            style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(48)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => onNavigate?.call(3),
                            icon: const Icon(Icons.pie_chart_outline_rounded,
                                size: 18),
                            label: const Text('Budget Planner'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.border),
                              backgroundColor: AppColors.surface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Recent Transactions',
                            style: AppText.sectionTitle),
                        GestureDetector(
                          onTap: () => onNavigate?.call(1),
                          child: const Row(
                            children: [
                              Text('See all',
                                  style: TextStyle(
                                      color: AppColors.primary, fontSize: 13)),
                              Icon(Icons.chevron_right,
                                  color: AppColors.primary, size: 18),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...recentTransactions.map((tx) => _TransactionTile(tx: tx)),
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

class _TransactionMock {
  final String title;
  final String date;
  final String amount;
  final bool isIncome;
  final IconData icon;

  _TransactionMock(
      {required this.title,
      required this.date,
      required this.amount,
      required this.isIncome,
      required this.icon});
}

class _TransactionTile extends StatelessWidget {
  final _TransactionMock tx;

  const _TransactionTile({required this.tx});

  @override
  Widget build(BuildContext context) {
    final color = tx.isIncome ? AppColors.income : AppColors.expense;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppShadows.subtle),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color:
                    tx.isIncome ? AppColors.incomePale : AppColors.expensePale,
                shape: BoxShape.circle),
            child: Icon(tx.icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textPrimary)),
                Text(tx.date, style: AppText.caption),
              ],
            ),
          ),
          Text(tx.amount,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: color, fontSize: 14)),
        ],
      ),
    );
  }
}
