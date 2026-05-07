// Company flow: OTP input, resend timer, and success navigation.

import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/router/app_router.dart';
import '../../../shared/l10n/app_localizations.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_scaffold.dart';

class CompanyOtpEmailVerificationScreen extends StatefulWidget {
  const CompanyOtpEmailVerificationScreen({super.key, required this.email});

  final String email;

  @override
  State<CompanyOtpEmailVerificationScreen> createState() =>
      _CompanyOtpEmailVerificationScreenState();
}

class _CompanyOtpEmailVerificationScreenState
    extends State<CompanyOtpEmailVerificationScreen> {
  final _c1 = TextEditingController();
  final _c2 = TextEditingController();
  final _c3 = TextEditingController();
  final _c4 = TextEditingController();
  int _seconds = 120;
  Timer? _timer;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_seconds == 0) return;
      setState(() => _seconds -= 1);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c1.dispose();
    _c2.dispose();
    _c3.dispose();
    _c4.dispose();
    super.dispose();
  }

  String get _otp => '${_c1.text}${_c2.text}${_c3.text}${_c4.text}';

  Future<void> _submit() async {
    final t = AppLocalizations.of(context);
    if (_otp.length != 4) {
      setState(() => _error = t.enterCode4);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).pushReplacementNamed(AppRoutes.companyResetPassword);
  }

  void _resend() {
    setState(() {
      _seconds = 120;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_seconds % 60).toString().padLeft(2, '0');

    return AppScaffold(
      title: 'OTP',
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            t.otpTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '${t.otpSubtitle}\n${widget.email}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              _OtpBox(controller: _c1),
              const SizedBox(width: 12),
              _OtpBox(controller: _c2),
              const SizedBox(width: 12),
              _OtpBox(controller: _c3),
              const SizedBox(width: 12),
              _OtpBox(controller: _c4),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                t.didntReceiveCode,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              TextButton(onPressed: _resend, child: Text(t.resend)),
            ],
          ),
          const SizedBox(height: 10),
          Center(child: Text('$minutes:$seconds')),
          const SizedBox(height: 18),
          AppButton(
            label: t.continueBtn,
            loading: _loading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextField(
        controller: controller,
        maxLength: 1,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: const InputDecoration(counterText: ''),
      ),
    );
  }
}
