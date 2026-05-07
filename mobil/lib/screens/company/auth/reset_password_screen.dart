// Company flow: enter and confirm a new password.

import 'package:flutter/material.dart';

import '../../../app/router/app_router.dart';
import '../../../shared/l10n/app_localizations.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_text_field.dart';

class CompanyResetPasswordScreen extends StatefulWidget {
  const CompanyResetPasswordScreen({super.key});

  @override
  State<CompanyResetPasswordScreen> createState() =>
      _CompanyResetPasswordScreenState();
}

class _CompanyResetPasswordScreenState extends State<CompanyResetPasswordScreen> {
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _loading = false;
  String? _newError;
  String? _confirmError;

  @override
  void dispose() {
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  bool _validate() {
    final t = AppLocalizations.of(context);
    final p1 = _newPassword.text;
    final p2 = _confirmPassword.text;
    setState(() {
      _newError = p1.length >= 8 ? null : t.mustBe8Chars;
      _confirmError = p2 == p1 ? null : t.mustMatch;
    });
    return _newError == null && _confirmError == null;
  }

  Future<void> _submit() async {
    if (!_validate()) return;
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).pushReplacementNamed(AppRoutes.companyPasswordChanged);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return AppScaffold(
      title: t.resetPassword,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            t.resetPassword,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            t.resetPasswordSub,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 24),
          AppTextField(
            label: t.newPassword,
            controller: _newPassword,
            hint: t.enterNewPassword,
            obscureText: _obscure1,
            validatorText: _newError,
            suffix: IconButton(
              onPressed: () => setState(() => _obscure1 = !_obscure1),
              icon: Icon(_obscure1 ? Icons.visibility_off : Icons.visibility),
            ),
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: t.confirmPassword,
            controller: _confirmPassword,
            hint: t.confirmPasswordHint,
            obscureText: _obscure2,
            validatorText: _confirmError,
            suffix: IconButton(
              onPressed: () => setState(() => _obscure2 = !_obscure2),
              icon: Icon(_obscure2 ? Icons.visibility_off : Icons.visibility),
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: t.verifyAccount,
            loading: _loading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
