import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

enum _NotifType { budgetAlert, goalMilestone, tip }

class _NotifItem {
  final _NotifType type;
  final String title;
  final String body;
  final String time;

  _NotifItem({required this.type, required this.title, required this.body, required this.time});
}

/// Notifications screen, reached via the bell icon on the Dashboard.
///
/// TODO: replace mock list with GET /api/notifications. Whether a
/// notification links back to a specific budget or goal (e.g. tapping a
/// budget-alert jumps straight to that category) depends on the still-open
/// schema question: adding budget_id/goal_id columns to the notification
/// table. Until that's settled, taps here are inert.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _NotifItem(
        type: _NotifType.budgetAlert,
        title: 'Groceries budget at 85%',
        body: "You've spent KES 6,800 of your KES 8,000 groceries budget this month.",
        time: '2h ago',
      ),
      _NotifItem(
        type: _NotifType.goalMilestone,
        title: 'Savings goal reached',
        body: "Nice work — you've hit 100% of your Emergency Fund target.",
        time: '1d ago',
      ),
      _NotifItem(
        type: _NotifType.tip,
        title: 'Spending is down this month',
        body: "You've spent 12% less than last month. Keep it up.",
        time: '2d ago',
      ),
      _NotifItem(
        type: _NotifType.budgetAlert,
        title: 'Transport budget exceeded',
        body: "You're KES 450 over your transport budget for June.",
        time: '3d ago',
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary), onPressed: () => Navigator.of(context).pop()),
                  const Text('Notifications', style: AppText.sectionTitle),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) => _NotificationTile(item: items[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final _NotifItem item;

  const _NotificationTile({required this.item});

  @override
  Widget build(BuildContext context) {
    late final IconData icon;
    late final Color color;
    late final Color bg;

    switch (item.type) {
      case _NotifType.budgetAlert:
        icon = Icons.warning_amber_rounded;
        color = AppColors.expense;
        bg = AppColors.expensePale;
        break;
      case _NotifType.goalMilestone:
        icon = Icons.emoji_events_rounded;
        color = AppColors.goldDeep;
        bg = AppColors.goldPale;
        break;
      case _NotifType.tip:
        icon = Icons.trending_up_rounded;
        color = AppColors.primary;
        bg = AppColors.primaryPale;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), boxShadow: AppShadows.subtle),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
                const SizedBox(height: 3),
                Text(item.body, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4)),
                const SizedBox(height: 6),
                Text(item.time, style: AppText.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
