import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../app/router/app_router.dart';
import '../../../shared/services/session_manager.dart';
import '../../../shared/services/recruitment_sync_service.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import 'sign_up_screen/sign_up_screen.dart';
import '../../../shared/l10n/app_localizations.dart';

class RecruitmentUserSignInScreen extends StatefulWidget {
  const RecruitmentUserSignInScreen({super.key});

  @override
  State<RecruitmentUserSignInScreen> createState() =>
      _RecruitmentUserSignInScreenState();
}

class _RecruitmentUserSignInScreenState extends State<RecruitmentUserSignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _emailError;
  String? _passError;

  final GoogleSignIn _googleSignInInstance = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final t = AppLocalizations.of(context);
    setState(() {
      _emailError = _email.text.contains('@') ? null : t.enterValidEmail;
      _passError = _password.text.isNotEmpty ? null : t.min8Chars;
    });
    
    if (_emailError != null || _passError != null) return;
    setState(() => _loading = true);

    try {
      final user = await RecruitmentSyncService.instance.login(
        email: _email.text.trim(),
        password: _password.text,
        expectedRole: 'user',
      );

      final name = user['name']?.toString() ?? 'User';

      await SessionManager.saveUserSession(
        email: _email.text.trim(),
        name: name,
      );

      if (!mounted) return;
      setState(() => _loading = false);
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.userWorkspace,
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      String msg = t.isAr ? 'البريد الإلكتروني أو كلمة المرور غير صحيحة' : 'Invalid email or password.';
      
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
          msg = t.isAr ? 'فشل الاتصال بالخادم، تحقق من الإنترنت' : 'Connection timeout. Check your internet.';
        } else if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
          msg = t.isAr ? 'البريد الإلكتروني أو كلمة المرور غير صحيحة' : 'Invalid email or password.';
        } else {
          msg = t.isAr ? 'حدث خطأ في الاتصال بالخادم' : 'Server connection error.';
        }
      } else {
        msg = e.toString().contains('حساب مخصص') || e.toString().contains('company accounts')
            ? e.toString().replaceAll('Exception: ', '')
            : msg;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _loading = true);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignInInstance.signIn();
      if (googleUser == null) {
        setState(() => _loading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Failed to get Google ID Token');
      }

      await RecruitmentSyncService.instance.googleLogin(idToken);
      
      final name = googleUser.displayName ?? googleUser.email.split('@').first;

      await SessionManager.saveUserSession(
        email: googleUser.email,
        name: name,
      );

      if (!mounted) return;
      
      setState(() => _loading = false);
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.userWorkspace,
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(t.signInBtn),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            t.tr(en: 'Welcome back', ar: 'أهلاً بك مجدداً'),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 24),
          
          AppTextField(
            label: t.emailAddress,
            controller: _email,
            hint: t.tr(en: 'Enter your email', ar: 'اكتب بريدك الإلكتروني'),
            keyboardType: TextInputType.emailAddress,
            validatorText: _emailError,
            prefixIcon: Icons.mail_outline,
          ),
          const SizedBox(height: 16),
          
          AppTextField(
            label: t.password,
            controller: _password,
            hint: t.tr(en: 'Enter your password', ar: 'اكتب كلمة المرور'),
            obscureText: _obscure,
            validatorText: _passError,
            prefixIcon: Icons.lock_outline,
            suffix: IconButton(
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
            ),
          ),
          
          Align(
            alignment: t.isAr ? Alignment.centerLeft : Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.companyForgotPassword),
              child: Text(t.forgotPassword),
            ),
          ),
          
          const SizedBox(height: 8),
          AppButton(
            label: t.signInBtn,
            loading: _loading,
            onPressed: _submit,
          ),
          
          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(t.tr(en: "OR", ar: "أو"), style: const TextStyle(color: Colors.grey)),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 24),
          
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _loading ? null : _handleGoogleSignIn,
            icon: _loading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)) : Brand(Brands.google, size: 24),
            label: Text(
              t.tr(en: "Continue with Google", ar: "المتابعة باستخدام جوجل"),
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
            ),
          ),
          
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                t.dontHaveAccount,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              /* زر إنشاء حساب جديد - ينقل المستخدم لصفحة التسجيل الموحدة */
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignUpScreen(),
                    ),
                  );
                },
                child: Text(
                  t.signUpBtn,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
