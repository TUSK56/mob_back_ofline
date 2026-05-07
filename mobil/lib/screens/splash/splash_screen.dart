import 'package:flutter/material.dart';
import '../../app/router/app_router.dart';
import '../../shared/widgets/app_button.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF9), // لون الخلفية الفاتح (كريمي)
      body: Column(
        children: [
          // الصورة الأساسية في أعلى الشاشة تماماً
          // تم تغليفها بـ Image.asset مع معالجة الخطأ لتجنب الشاشة الحمراء
          Image.asset(
            'assets/company/Onboarding/image 42 1.png',
            fit: BoxFit.contain, // يضمن ظهور الصورة كاملة داخل المساحة
            width: double.infinity,
            height: size.height * 0.38, // تقليل الارتفاع قليلاً لتناسب الشاشة
            errorBuilder: (context, error, stackTrace) => Container(
              height: size.height * 0.38,
              color: Colors.grey[200],
              child: const Icon(Icons.image_not_supported, size: 50),
            ),
          ),

        //  const SizedBox(height: 0),

          // النصوص التوضيحية والعناصر الزخرفية
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // العناصر الزخرفية (الخطوط)
                  Positioned(
                    top: 120,
                    left: 10,
                    child: Image.asset(
                      'assets/company/Onboarding/Vector 2355.png',
                      width: 150,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                  Positioned(
                    top: 100,
                    right: -10,
                    child: Image.asset(
                      'assets/company/Onboarding/Rectangle 2730 (Stroke).png',
                      width: 180,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                  Positioned(
                    top: 180,
                    left: -20,
                    child: Image.asset(
                      'assets/company/Onboarding/Rectangle 2733.png',
                      width: 240,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),

                  // النص الرئيسي باستخدام Text.rich لضمان التوافق
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          style: const TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                            fontFamily: 'Muli',
                            color: Colors.black,
                          ),
                          children: [
                            const TextSpan(text: 'Find '),
                            const TextSpan(
                              text: 'your ',
                              style: TextStyle(color: Color(0xFF4A80D4)),
                            ),
                            const TextSpan(
                              text: 'dream job ',
                              style: TextStyle(color: Color(0xFFF28F44)),
                            ),
                          ],
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                          style: const TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                            color: Colors.black,
                          ),
                          children: [
                            const TextSpan(text: 'on '),
                            const TextSpan(
                              text: 'Jobito',
                              style: TextStyle(color: Color(0xFFF28F44)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // زر Get Started في الأسفل
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 40),
            child: AppButton(
              label: 'Get Started',
              onPressed: () {
                Navigator.of(context).pushReplacementNamed(AppRoutes.roleSelection);
              },
            ),
          ),
        ],
      ),
    );
  }
}
