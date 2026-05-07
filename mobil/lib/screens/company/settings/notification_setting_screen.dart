// Per-channel notification toggles.

import 'package:flutter/material.dart';

import '../../../app/router/app_router.dart';
import '../../../shared/l10n/app_localizations.dart';
import '../../../shared/widgets/app_scaffold.dart';

class CompanyNotificationSettingScreen extends StatelessWidget {
  const CompanyNotificationSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return AppScaffold(
      title: t.tr(en: 'Settings', ar: 'الإعدادات'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OutlinedButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.companyAppearanceDark),
              child: Text(t.tr(en: 'Appearance', ar: 'المظهر')),
            ),
            const SizedBox(height: 14),
            Text(
              t.tr(
                en: 'This screen is intentionally minimal in the design.\nUse it as an entry to notification preferences.',
                ar: 'هذه الشاشة بسيطة عمدًا في التصميم.\nاستخدمها كنقطة دخول لتفضيلات الإشعارات.',
              ),
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

