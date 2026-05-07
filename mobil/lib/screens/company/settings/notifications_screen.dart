import 'package:flutter/material.dart';

import '../../../shared/l10n/app_localizations.dart';
import '../../../shared/widgets/app_scaffold.dart';

class CompanyNotificationsScreen extends StatelessWidget {
  const CompanyNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final List<dynamic> notifications = []; // Empty for now

    return AppScaffold(
      title: t.notifications,
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 80,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t.tr(en: "No notifications yet", ar: "لا توجد إشعارات بعد"),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

