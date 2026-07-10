import 'package:flutter/material.dart';
import '../widgets/malihub_bottom_nav.dart';
import 'dashboard_screen.dart';
import 'transactions_screen.dart';
import 'analytics_screen.dart';
import 'budget_planner_screen.dart';
import 'login_screen.dart';

/// Hosts the four main tabs (Home, Transactions, Insights, Budget) behind
/// the shared bottom navigation bar, shown after a successful login.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  void _onNavigate(int index) => setState(() => _currentIndex = index);

  void _handleLogout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(onNavigate: _onNavigate, onLogout: _handleLogout),
      const TransactionsScreen(),
      const AnalyticsScreen(),
      const BudgetPlannerScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: MalihubBottomNav(currentIndex: _currentIndex, onTap: _onNavigate),
    );
  }
}
