// Company sign-in with validation and social placeholder.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../app/router/app_router.dart';
// ... rest of imports
import '../../../shared/l10n/app_localizations.dart';
import '../../../shared/services/recruitment_sync_service.dart';
import '../../../shared/services/session_manager.dart';
import '../../../shared/state/company_store.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_text_field.dart';

class CompanySignInScreen extends StatefulWidget {
  const CompanySignInScreen({super.key});

  @override
  State<CompanySignInScreen> createState() => _CompanySignInScreenState();
}

class _CompanySignInScreenState extends State<CompanySignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _emailError;
  String? _passwordError;

  final GoogleSignIn _googleSignInInstance = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  bool _validate() {
    final t = AppLocalizations.of(context);
    final email = _email.text.trim();
    final pass = _password.text;
    setState(() {
      _emailError = email.contains('@') ? null : t.enterValidEmail;
      _passwordError = pass.isNotEmpty ? null : t.min8Chars;
    });
    return _emailError == null && _passwordError == null;
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _loading = true);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignInInstance
          .signIn();
      if (googleUser == null) {
        setState(() => _loading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Failed to get Google ID Token');
      }

      final userData = await RecruitmentSyncService.instance.googleLogin(
        idToken,
      );

      setState(() => _loading = false);
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.companyDashboard, (route) => false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In failed: ${e.toString()}')),
      );
    }
  }

  Future<void> _submit() async {
    if (!_validate()) return;
    setState(() => _loading = true);

    try {
      final userData = await RecruitmentSyncService.instance.login(
        email: _email.text.trim(),
        password: _password.text,
        expectedRole: 'company',
      );

      await RecruitmentSyncService.instance.startPolling();

      setState(() => _loading = false);
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.companyDashboard, (route) => false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      final t = AppLocalizations.of(context);
      String msg = t.isAr
          ? 'البريد الإلكتروني أو كلمة المرور غير صحيحة'
          : 'Invalid email or password.';

      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          msg = t.isAr
              ? 'فشل الاتصال بالخادم، تحقق من الإنترنت'
              : 'Connection timeout. Check your internet.';
        } else if (e.response?.statusCode == 401 ||
            e.response?.statusCode == 403) {
          msg = t.isAr
              ? 'البريد الإلكتروني أو كلمة المرور غير صحيحة'
              : 'Invalid email or password.';
        } else {
          msg = t.isAr
              ? 'حدث خطأ في الاتصال بالخادم'
              : 'Server connection error.';
        }
      } else {
        msg =
            e.toString().contains('حساب شركة') ||
                e.toString().contains('company account')
            ? e.toString().replaceAll('Exception: ', '')
            : msg;
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return AppScaffold(
      title: null,
      showBack: true,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 18),
          Text(
            t.signInToAccount,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: 30),
          AppTextField(
            label: t.companyEmailAddress,
            controller: _email,
            hint: t.enterYourEmail,
            keyboardType: TextInputType.emailAddress,
            validatorText: _emailError,
            onChanged: (_) =>
                _emailError == null ? null : setState(() => _emailError = null),
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: t.password,
            controller: _password,
            hint: t.enterYourPassword,
            obscureText: _obscure,
            validatorText: _passwordError,
            onChanged: (_) => _passwordError == null
                ? null
                : setState(() => _passwordError = null),
            suffix: IconButton(
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
            ),
          ),
          Align(
            alignment: t.isAr ? Alignment.centerLeft : Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.of(
                context,
              ).pushNamed(AppRoutes.companyForgotPassword),
              child: Text(t.forgotPassword),
            ),
          ),
          const SizedBox(height: 10),
          AppButton(
            label: t.continueBtn,
            loading: _loading,
            onPressed: _submit,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: Theme.of(context).dividerColor.withOpacity(0.15),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(t.orSignInWith),
              ),
              Expanded(child: Divider(color: Colors.white.withOpacity(0.15))),
            ],
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: _loading ? null : _handleGoogleSignIn,
            icon: SvgPicture.asset(
              'assets/company/icon/google_g.svg',
              width: 18,
              height: 18,
            ),
            label: const Text('Google'),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                t.dontHaveAccount,
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.companySignUp),
                child: Text(t.signUpBtn),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
