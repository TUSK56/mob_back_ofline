// Onboarding carousel / value prop screen.

import 'package:flutter/material.dart';

import '../../../app/router/app_router.dart';
import '../../../constants/app_images.dart';
import '../../../shared/l10n/app_localizations.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_scaffold.dart';

class CompanyOnboardingFutureStartsScreen extends StatelessWidget {
  const CompanyOnboardingFutureStartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return AppScaffold(
      showBack: true,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Spacer(),
            Image.asset(
              AppImages.companyOnboarding3,
              height: 260,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 22),
            Text(
              t.futureStartsHere,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              t.futureStartsSub,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 16,
                  ),
            ),
            const Spacer(),
            AppButton(
              label: t.getStarted,
              onPressed: () => Navigator.of(context).pushReplacementNamed(
                AppRoutes.companySignIn,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
