import 'package:flutter/material.dart';
import '../../../constants/app_images.dart';
import '../../../shared/l10n/app_localizations.dart';
import '../core/app_colors.dart';

class Screen3 extends StatelessWidget {
  final VoidCallback onNext;
  final int currentPage;

  const Screen3({super.key, required this.onNext, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF011931),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Image.asset(
                AppImages.companyOnboarding3,
                height: MediaQuery.of(context).size.height * 0.3,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.broken_image,
                    size: 100,
                    color: Colors.white,
                  );
                },
              ),
              const Spacer(flex: 2),
              Text(
                t.userTr(
                  'onboarding.title3',
                  fallbackEn: 'Your Future Starts Here',
                  fallbackAr: 'مستقبلك يبدأ من هنا',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                t.userTr(
                  'onboarding.subtitle3',
                  fallbackEn:
                      'Thousands of job opportunities are waiting\nfor you',
                  fallbackAr: 'آلاف فرص العمل في انتظارك',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 3),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      3,
                      (index) =>
                          _buildIndicator(isActive: index == currentPage),
                    ),
                  ),
                  buildNextButton(onNext, t),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildNextButton(VoidCallback onPressed, AppLocalizations t) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF0A2A4A), // Dark
              Color(0xFF2F5F8F), // Light
              Color.fromARGB(255, 118, 159, 178),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(70),
            bottomLeft: Radius.circular(25),
            topRight: Radius.circular(25),
            bottomRight: Radius.circular(70),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Text(
          t.userTr('onboarding.next', fallbackEn: 'Next', fallbackAr: 'التالي'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 6),
      width: isActive ? 32 : 12,
      height: 10,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : AppColors.primary,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}

