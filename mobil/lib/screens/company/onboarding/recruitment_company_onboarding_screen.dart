import 'package:flutter/material.dart';

import '../../../app/router/app_router.dart';
import '../../../shared/widgets/app_button.dart';

class RecruitmentCompanyOnboardingScreen extends StatefulWidget {
  const RecruitmentCompanyOnboardingScreen({super.key});

  @override
  State<RecruitmentCompanyOnboardingScreen> createState() =>
      _RecruitmentCompanyOnboardingScreenState();
}

class _RecruitmentCompanyOnboardingScreenState
    extends State<RecruitmentCompanyOnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  final List<_CompanySlide> _slides = const [
    _CompanySlide(
      title: 'Post Open Roles Quickly',
      subtitle: 'Create jobs with smart fields and reach candidates instantly.',
      icon: Icons.post_add_rounded,
    ),
    _CompanySlide(
      title: 'Manage Candidate Pipeline',
      subtitle: 'Move applicants through review, shortlist, and hire.',
      icon: Icons.groups_2_rounded,
    ),
    _CompanySlide(
      title: 'Sync Updates With Candidates',
      subtitle: 'Every status update and message appears in user timeline.',
      icon: Icons.sync_alt_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (value) => setState(() => _index = value),
                itemBuilder: (context, i) {
                  final slide = _slides[i];
                  return Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 56,
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                          child: Icon(slide.icon, size: 56),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          slide.subtitle,
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
                    _slides.length,
                    (i) => Container(
                      width: 24,
                      height: 6,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: i == _index
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.secondary.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 180,
                    child: AppButton(
                      label: _index == _slides.length - 1 ? 'Continue' : 'Next',
                      onPressed: () {
                        if (_index == _slides.length - 1) {
                          Navigator.of(context)
                              .pushReplacementNamed(AppRoutes.companySignInNew);
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

class _CompanySlide {
  const _CompanySlide({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}
