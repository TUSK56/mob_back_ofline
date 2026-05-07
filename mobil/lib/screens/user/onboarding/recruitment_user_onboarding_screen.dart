import 'package:flutter/material.dart';

import '../../../app/router/app_router.dart';
import '../../../shared/l10n/app_localizations.dart';
import '../../../shared/widgets/app_button.dart';

class RecruitmentUserOnboardingScreen extends StatefulWidget {
  const RecruitmentUserOnboardingScreen({super.key});

  @override
  State<RecruitmentUserOnboardingScreen> createState() =>
      _RecruitmentUserOnboardingScreenState();
}

class _RecruitmentUserOnboardingScreenState
    extends State<RecruitmentUserOnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    
    final List<_OnboardingItem> items = [
      _OnboardingItem(
        title: t.tr(en: 'Find Jobs That Match You', ar: 'ابحث عن وظائف تناسبك'),
        subtitle: t.tr(en: 'Search with filters by role, location, and salary.', ar: 'ابحث باستخدام الفلاتر حسب الدور والموقع والراتب.'),
        icon: Icons.search_rounded,
      ),
      _OnboardingItem(
        title: t.tr(en: 'Apply With Full Profile', ar: 'قدّم بملف شخصي كامل'),
        subtitle: t.tr(en: 'Send CV, portfolio, and cover letter in one flow.', ar: 'أرسل السيرة الذاتية ومعرض الأعمال وخطاب التقديم في مسار واحد.'),
        icon: Icons.assignment_turned_in_rounded,
      ),
      _OnboardingItem(
        title: t.tr(en: 'Track Every Hiring Stage', ar: 'تتبع كل مرحلة توظيف'),
        subtitle: t.tr(en: 'Get live updates from review to offer.', ar: 'احصل على تحديثات مباشرة من المراجعة إلى العرض.'),
        icon: Icons.timeline_rounded,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: items.length,
                onPageChanged: (value) => setState(() => _index = value),
                itemBuilder: (context, i) {
                  final item = items[i];
                  return Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 56,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                          child: Icon(item.icon, size: 58),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item.subtitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ...List.generate(
                    items.length,
                    (i) => Container(
                      width: 24,
                      height: 6,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: i == _index
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 180,
                    child: AppButton(
                      label: _index == items.length - 1 ? t.getStarted : t.next,
                      onPressed: () {
                        if (_index == items.length - 1) {
                          Navigator.of(context)
                              .pushReplacementNamed(AppRoutes.userSignInNew);
                          return;
                        }
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingItem {
  const _OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}
