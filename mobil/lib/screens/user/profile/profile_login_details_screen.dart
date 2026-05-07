import 'package:flutter/material.dart';
import '../../../shared/l10n/app_localizations.dart';
import 'edit_profile_screen.dart';
import 'setting_profile/notifications.dart';
import 'setting_profile/preferences.dart';

class ProfileLoginDetailsScreen extends StatefulWidget {
  const ProfileLoginDetailsScreen({super.key});

  @override
  State<ProfileLoginDetailsScreen> createState() => _ProfileLoginDetailsScreenState();
}

class _ProfileLoginDetailsScreenState extends State<ProfileLoginDetailsScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isAr = t.isAr;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          t.tr(en: "Edit Profile", ar: "تعديل الملف الشخصي"),
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTabItem(t.tr(en: "Profile Setting", ar: "إعدادات الملف"), false, () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
                  }),
                  const SizedBox(width: 20),
                  _buildTabItem(t.tr(en: "Account Security", ar: "أمان الحساب"), true, () {}),
                  const SizedBox(width: 20),
                  _buildTabItem(t.tr(en: "Notification", ar: "الإشعارات"), false, () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Notifications()));
                  }),
                  const SizedBox(width: 20),
                  _buildTabItem(t.tr(en: "Preferences", ar: "التفضيلات"), false, () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Preferences()));
                  }),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Divider(color: Theme.of(context).dividerColor.withValues(alpha: 0.12), height: 1),
            const SizedBox(height: 30),

            // Account Security Title
            Text(t.tr(en: "Account Security", ar: "أمان الحساب"), style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(t.tr(en: "Update your password regularly to keep your account safe.", ar: "قم بتحديث كلمة المرور الخاصة بك بانتظام للحفاظ على أمان حسابك."), style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), fontSize: 13)),
            const SizedBox(height: 30),

            // Current Password
            _buildPasswordField(
              t.tr(en: "Current Password", ar: "كلمة المرور الحالية"), 
              "********", 
              _currentPasswordController,
              _obscureCurrent,
              () => setState(() => _obscureCurrent = !_obscureCurrent),
            ),
            const SizedBox(height: 20),
            
            // New & Confirm Password
            Row(
              children: [
                Expanded(
                  child: _buildPasswordField(
                    t.tr(en: "New Password", ar: "كلمة المرور الجديدة"), 
                    "********", 
                    _newPasswordController,
                    _obscureNew,
                    () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildPasswordField(
                    t.tr(en: "Confirm Password", ar: "تأكيد كلمة المرور"), 
                    "********", 
                    _confirmPasswordController,
                    _obscureConfirm,
                    () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 60),
            Divider(color: Theme.of(context).dividerColor.withValues(alpha: 0.12), height: 1),
            const SizedBox(height: 30),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: Align(
                alignment: isAr ? Alignment.centerLeft : Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                     ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Password Updated Successfully!")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(t.tr(en: "Save Profile", ar: "حفظ الملف الشخصي"), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(String title, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38), 
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal, 
              fontSize: 14,
            ),
          ),
          if (isActive)
            Container(
              margin: const EdgeInsets.only(top: 8),
              height: 2,
              width: 60,
              color: Theme.of(context).colorScheme.primary,
            ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(String label, String hint, TextEditingController controller, bool obscure, VoidCallback onToggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3), fontSize: 13),
            suffixIcon: TextButton(
              onPressed: onToggle,
              child: Text(obscure ? "Show" : "Hide", style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12)),
            ),
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.12))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.12))),
          ),
        ),
      ],
    );
  }
}


