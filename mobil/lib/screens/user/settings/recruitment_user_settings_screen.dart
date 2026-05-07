import 'package:flutter/material.dart';
import '../../../app/router/app_router.dart';
import '../../../shared/services/recruitment_sync_service.dart';
import '../../../shared/state/locale_controller.dart';
import '../../../shared/state/theme_controller.dart';

class RecruitmentUserSettingsScreen extends StatelessWidget {
  const RecruitmentUserSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localeController = LocaleController.instance;
    final themeController = ThemeController.instance;
    return Scaffold(
      appBar: AppBar(title: Text('Settings', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Appearance', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeController.themeMode,
            builder: (context, mode, _) => Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Light'),
                    trailing: mode == ThemeMode.light
                        ? const Icon(Icons.check)
                        : null,
                    onTap: themeController.setLight,
                  ),
                  ListTile(
                    title: const Text('Dark'),
                    trailing:
                        mode == ThemeMode.dark ? const Icon(Icons.check) : null,
                    onTap: themeController.setDark,
                  ),
                  ListTile(
                    title: const Text('System'),
                    trailing: mode == ThemeMode.system
                        ? const Icon(Icons.check)
                        : null,
                    onTap: () =>
                        themeController.themeMode.value = ThemeMode.system,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text('Language', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ValueListenableBuilder<Locale>(
            valueListenable: localeController.locale,
            builder: (context, locale, _) => Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('English'),
                    trailing: locale.languageCode == 'en'
                        ? const Icon(Icons.check)
                        : null,
                    onTap: () {
                      if (locale.languageCode != 'en') localeController.toggle();
                    },
                  ),
                  ListTile(
                    title: const Text('العربية'),
                    trailing: locale.languageCode == 'ar'
                        ? const Icon(Icons.check)
                        : null,
                    onTap: () {
                      if (locale.languageCode != 'ar') localeController.toggle();
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await RecruitmentSyncService.instance.logout();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.roleSelection, (route) => false);
                }
              },
              ),
            ),
        ],
      ),
    );
  }
}
