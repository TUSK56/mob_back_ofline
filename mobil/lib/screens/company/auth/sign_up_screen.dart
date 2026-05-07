// Company registration form and navigation to next steps.

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../app/router/app_router.dart';
import '../../../shared/l10n/app_localizations.dart';
import '../../../shared/state/company_store.dart';
import '../../../shared/services/session_manager.dart';
import '../../../shared/services/recruitment_sync_service.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_text_field.dart';

class CompanySignUpScreen extends StatefulWidget {
  const CompanySignUpScreen({super.key});

  @override
  State<CompanySignUpScreen> createState() => _CompanySignUpScreenState();
}

class _CompanySignUpScreenState extends State<CompanySignUpScreen> {
  final _companyName = TextEditingController();
  final _email = TextEditingController();
  final _companyNumber = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _address = TextEditingController();
  final _taxNumber = TextEditingController();
  final _commercialRegister = TextEditingController();
  final _nationalNumber = TextEditingController();

  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _agree = false;
  bool _loading = false;

  String? _companyNameError;
  String? _emailError;
  String? _companyNumberError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _companyName.dispose();
    _email.dispose();
    _companyNumber.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _address.dispose();
    _taxNumber.dispose();
    _commercialRegister.dispose();
    _nationalNumber.dispose();
    super.dispose();
  }

  bool _validate() {
    final t = AppLocalizations.of(context);
    final email = _email.text.trim();
    final pass = _password.text;
    final confirm = _confirmPassword.text;
    setState(() {
      _companyNameError = _companyName.text.trim().isNotEmpty ? null : t.required;
      _emailError = email.contains('@') ? null : t.enterValidEmail;
      _companyNumberError =
          _companyNumber.text.trim().length >= 6 ? null : t.enterCompanyNumber;
      _passwordError = pass.length >= 8 ? null : t.min8Chars;
      _confirmPasswordError = confirm == pass ? null : t.passwordsNoMatch;
    });
    return _companyNameError == null &&
        _emailError == null &&
        _companyNumberError == null &&
        _passwordError == null &&
        _confirmPasswordError == null &&
        _agree;
  }

  Future<void> _submit() async {
    if (!_validate()) return;
    setState(() => _loading = true);
    
    try {
      await RecruitmentSyncService.instance.register(
        email: _email.text.trim(),
        password: _password.text,
        name: _companyName.text.trim(),
        role: 'company',
      );

      if (!mounted) return;

      setState(() => _loading = false);
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.companyWorkspace, (route) => false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      final t = AppLocalizations.of(context);
      String msg;
      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        if (statusCode == 409 || statusCode == 400) {
          msg = t.isAr ? 'البريد الإلكتروني مستخدم بالفعل، جرّب بريداً آخر.' : 'Email already registered. Try a different one.';
        } else if (statusCode == null) {
          msg = t.isAr ? 'تعذّر الاتصال بالخادم، تحقق من الإنترنت.' : 'Cannot reach server. Check your internet.';
        } else {
          msg = t.isAr ? 'فشل التسجيل، حاول مرة أخرى.' : 'Registration failed. Please try again.';
        }
      } else {
        msg = t.isAr ? 'فشل التسجيل، حاول مرة أخرى.' : 'Registration failed. Please try again.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
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
            t.createAccount,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 26),
          const SizedBox(height: 26),
          AppTextField(
            label: t.companyName,
            controller: _companyName,
            hint: t.enterCompanyName,
            validatorText: _companyNameError,
            onChanged: (_) => _companyNameError == null
                ? null
                : setState(() => _companyNameError = null),
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: t.companyEmail,
            controller: _email,
            hint: t.enterYourEmail,
            keyboardType: TextInputType.emailAddress,
            validatorText: _emailError,
            onChanged: (_) =>
                _emailError == null ? null : setState(() => _emailError = null),
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.companyNumber,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: 8),
              IntlPhoneField(
                controller: _companyNumber,
                decoration: InputDecoration(
                  hintText: t.enterCompanyNumberHint,
                  errorText: _companyNumberError,
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceBright,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                initialCountryCode: 'EG',
                flagsButtonPadding: const EdgeInsets.symmetric(horizontal: 8),
                dropdownDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                onChanged: (phone) {
                  if (_companyNumberError != null) {
                    setState(() => _companyNumberError = null);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: t.password,
            controller: _password,
            hint: t.enterYourPassword,
            obscureText: _obscure1,
            validatorText: _passwordError,
            suffix: IconButton(
              onPressed: () => setState(() => _obscure1 = !_obscure1),
              icon: Icon(_obscure1 ? Icons.visibility_off : Icons.visibility),
            ),
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: t.confirmPassword,
            controller: _confirmPassword,
            hint: t.confirmYourPassword,
            obscureText: _obscure2,
            validatorText: _confirmPasswordError,
            suffix: IconButton(
              onPressed: () => setState(() => _obscure2 = !_obscure2),
              icon: Icon(_obscure2 ? Icons.visibility_off : Icons.visibility),
            ),
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: t.address,
            controller: _address,
            hint: t.enterAddress,
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: t.taxNumber,
            controller: _taxNumber,
            hint: t.enterTaxNumber,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: t.tr(en: 'Commercial Register', ar: 'السجل التجاري'),
            controller: _commercialRegister,
            hint: t.tr(en: 'Enter Commercial Register', ar: 'أدخل السجل التجاري'),
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: t.tr(en: 'National Number of Official', ar: 'الرقم القومي للمسؤول'),
            controller: _nationalNumber,
            hint: t.tr(en: 'Enter National Number', ar: 'أدخل الرقم القومي للمسؤول'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Checkbox(
                value: _agree,
                onChanged: _loading ? null : (v) => setState(() => _agree = v ?? false),
              ),
              Expanded(
                child: Text(
                  t.agreeTerms,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
          if (!_agree)
            Padding(
              padding: EdgeInsetsDirectional.only(start: 8, bottom: 8),
              child: Text(
                t.acceptTermsMsg,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ),
          const SizedBox(height: 10),
          AppButton(
            label: t.continueBtn,
            loading: _loading,
            onPressed: _submit,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                t.alreadyRegistered,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(t.signInBtn),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
