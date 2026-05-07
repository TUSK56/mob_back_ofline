// Company settings root: account, appearance, help, sign out.

import 'package:flutter/material.dart';

import '../../../app/router/app_router.dart';
import '../../../shared/l10n/app_localizations.dart';
import '../../../shared/services/recruitment_sync_service.dart';
import '../../../shared/widgets/app_scaffold.dart';

class CompanySettingsScreen extends StatelessWidget {
  const CompanySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return AppScaffold(
      title: t.settings,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
          _SettingTile(
            title: t.profileSettings,
            icon: Icons.person_outline,
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.companyProfileOverview),
          ),
          const SizedBox(height: 8),
          _SettingTile(
            title: t.accountSecurity,
            icon: Icons.security_outlined,
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.companyAccountSecurity),
          ),
          const SizedBox(height: 8),
          _SettingTile(
            title: t.tr(en: 'Appearance', ar: 'المظهر'),
            icon: Icons.palette_outlined,
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.companyAppearanceLight),
          ),
        ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed(AppRoutes.companyHelpCenter),
                  icon: const Icon(Icons.info_outline),
                  label: Text(
                    t.helpCenter,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFFF6C52),
                    padding: EdgeInsets.zero,
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    await RecruitmentSyncService.instance.logout();
                    if (context.mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRoutes.roleSelection, (route) => false);
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: Text(
                    t.tr(en: 'Logout', ar: 'تسجيل خروج'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFFF6C52),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: Theme.of(context).textTheme.titleSmall),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
