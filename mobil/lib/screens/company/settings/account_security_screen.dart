import 'package:flutter/material.dart';

import '../../../shared/l10n/app_localizations.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_text_field.dart';

class CompanyAccountSecurityScreen extends StatefulWidget {
  const CompanyAccountSecurityScreen({super.key});

  @override
  State<CompanyAccountSecurityScreen> createState() => _CompanyAccountSecurityScreenState();
}

class _CompanyAccountSecurityScreenState extends State<CompanyAccountSecurityScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
  }
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // فصل الـ Loading عن بعض
  bool _isEmailLoading = false;
  bool _isPasswordLoading = false;

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ✅ تحديث الإيميل
  Future<void> _updateEmail() async {
    final t = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final email = _emailController.text.trim();
    
    if (email.isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(t.tr(en: 'Please enter an email', ar: 'الرجاء إدخال البريد الإلكتروني'))),
      );
      return;
    }

    setState(() => _isEmailLoading = true);
    try {
      // TODO: استبدل الكود ده بالـ API Call الحقيقي
      await Future.delayed(const Duration(milliseconds: 800));
      messenger.showSnackBar(
        SnackBar(content: Text(t.saved)),
      );
    } finally {
      if (mounted) setState(() => _isEmailLoading = false);
    }
  }

  // ✅ تحديث كلمة المرور
  Future<void> _updatePassword() async {
    final t = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final current = _currentPasswordController.text;
    final newPass = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(t.tr(en: 'All password fields are required', ar: 'جميع حقول كلمة المرور مطلوبة'))),
      );
      return;
    }
    if (newPass.length < 6) {
      messenger.showSnackBar(
        SnackBar(content: Text(t.tr(en: 'Password must be at least 6 characters', ar: 'يجب أن تكون كلمة المرور 6 أحرف على الأقل'))),
      );
      return;
    }
    if (newPass != confirm) {
      messenger.showSnackBar(
        SnackBar(content: Text(t.tr(en: 'Passwords do not match', ar: 'كلمات المرور غير متطابقة'))),
      );
      return;
    }

    setState(() => _isPasswordLoading = true);
    try {
      // TODO: استبدل الكود ده بالـ API Call الحقيقي
      await Future.delayed(const Duration(milliseconds: 800));
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      messenger.showSnackBar(
        SnackBar(content: Text(t.saved)),
      );
    } finally {
      if (mounted) setState(() => _isPasswordLoading = false);
    }
  }



  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return AppScaffold(
      title: t.profileSettings, // Match title of profile settings
      showBack: true,
      body: Column(
        children: [
          const Divider(height: 1, thickness: 1),
          Material(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: TabBar(
              controller: _tabController,
              onTap: (index) {
                if (index == 0) {
                  Navigator.pop(context);
                } else if (index == 2) {
                  Navigator.pushReplacementNamed(context, '/company/settings/appearance_light');
                }
              },
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              indicatorColor: Theme.of(context).colorScheme.primary,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
              tabs: [
                Tab(text: t.profileSettings),
                Tab(text: t.accountSecurity),
                Tab(text: t.tr(en: "Appearance", ar: "المظهر")),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _sectionTitle(t.tr(en: 'Email Address', ar: 'البريد الإلكتروني')),
          const SizedBox(height: 10),
          AppTextField(
            label: '',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          Align(
            alignment: t.isAr ? Alignment.centerLeft : Alignment.centerRight,
            child: AppButton(
              label: t.tr(en: 'Update', ar: 'تحديث'),
              onPressed: _updateEmail,
              loading: _isEmailLoading,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          _sectionTitle(t.tr(en: 'Change Password', ar: 'تغيير كلمة المرور')),
          const SizedBox(height: 16),
          AppTextField(
            label: t.currentPassword,
            controller: _currentPasswordController,
            obscureText: true,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: t.newPasswordLabel,
            controller: _newPasswordController,
            obscureText: true,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: t.confirmNewPassword,
            controller: _confirmPasswordController,
            obscureText: true,
          ),
          const SizedBox(height: 24),
          AppButton(
            label: t.tr(en: 'Update Password', ar: 'تحديث كلمة المرور'),
            onPressed: _updatePassword,
            loading: _isPasswordLoading,
          ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
    );
  }


}