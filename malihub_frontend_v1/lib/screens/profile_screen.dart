import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Profile / account screen, reached by tapping the avatar on the Dashboard.
///
/// Replaces a bare "tap avatar to log out" pattern with a real settings
/// surface. Everything except Logout is a stub for now — TODO markers show
/// exactly where each would connect once the backend supports it.
class ProfileScreen extends StatelessWidget {
  final VoidCallback onLogout;

  const ProfileScreen({super.key, required this.onLogout});

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out of Malihub?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary))),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Log Out', style: TextStyle(color: AppColors.expense))),
        ],
      ),
    );
    if (confirmed == true) {
      // TODO: clear the stored JWT (e.g. flutter_secure_storage) here.
      onLogout();
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  const Text('Profile', style: AppText.sectionTitle),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18), boxShadow: AppShadows.subtle),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(color: AppColors.primaryPale, shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: const Text('AO', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Amara Odhiambo', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary)),
                              SizedBox(height: 2),
                              Text('amara@example.com', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('ACCOUNT', style: AppText.eyebrow),
                  const SizedBox(height: 8),
                  _SettingsTile(icon: Icons.person_outline_rounded, label: 'Edit profile', onTap: () {
                    // TODO: PUT /api/users/:id once the backend endpoint exists.
                  }),
                  _SettingsTile(icon: Icons.lock_outline_rounded, label: 'Security', onTap: () {
                    // TODO: password change flow, POST /api/auth/change-password.
                  }),
                  _SettingsTile(icon: Icons.notifications_none_rounded, label: 'Notification preferences', onTap: () {
                    // TODO: per-category notification toggles once notification settings exist.
                  }),
                  const SizedBox(height: 20),
                  const Text('SUPPORT', style: AppText.eyebrow),
                  const SizedBox(height: 8),
                  _SettingsTile(icon: Icons.help_outline_rounded, label: 'Help & support', onTap: () {}),
                  _SettingsTile(icon: Icons.info_outline_rounded, label: 'About Malihub', onTap: () {}),
                  const SizedBox(height: 20),
                  _SettingsTile(
                    icon: Icons.logout_rounded,
                    label: 'Log out',
                    iconColor: AppColors.expense,
                    labelColor: AppColors.expense,
                    onTap: () => _confirmLogout(context),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? labelColor;

  const _SettingsTile({required this.icon, required this.label, required this.onTap, this.iconColor, this.labelColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Icon(icon, color: iconColor ?? AppColors.textSecondary, size: 20),
        title: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: labelColor ?? AppColors.textPrimary)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
        dense: true,
      ),
    );
  }
}
