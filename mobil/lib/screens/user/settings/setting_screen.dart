import 'package:flutter/material.dart';
import '../../../app/router/app_router.dart';
import '../../../shared/l10n/app_localizations.dart';
import '../profile/edit_profile_screen.dart';
import '../profile/profile_login_details_screen.dart';
import '../profile/setting_profile/notifications.dart';
import '../profile/setting_profile/preferences.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  void _showLogoutDialog() {
    final t = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          t.tr(en: "Logout", ar: "تسجيل الخروج"),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          t.tr(
            en: "Are you sure you want to log out?",
            ar: "هل أنت متأكد أنك تريد تسجيل الخروج؟",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.cancel, style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.roleSelection, // Assuming roleSelection is the initial/sign-in entry
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              t.tr(en: "Logout", ar: "خروج"),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
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
          t.settings,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(isAr ? Icons.arrow_forward_ios : Icons.arrow_back_ios, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              t.tr(en: "Account Settings", ar: "إعدادات الحساب"),
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            _buildSettingItem(
              icon: Icons.person_outline,
              title: t.tr(en: "Profile Setting", ar: "إعدادات الملف الشخصي"),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen())),
            ),
            _buildSettingItem(
              icon: Icons.security_outlined,
              title: t.tr(en: "Account Security", ar: "أمان الحساب"),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileLoginDetailsScreen())),
            ),
            _buildSettingItem(
              icon: Icons.notifications_none,
              title: t.tr(en: "Notification", ar: "الإشعارات"),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Notifications())),
            ),
            _buildSettingItem(
              icon: Icons.tune_outlined,
              title: t.tr(en: "Preferences", ar: "التفضيلات"),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Preferences())),
            ),

            const SizedBox(height: 40),
            _buildSettingItem(
              icon: Icons.logout,
              title: t.tr(en: "Logout", ar: "تسجيل الخروج"),
              titleColor: Colors.redAccent,
              showArrow: false,
              onTap: _showLogoutDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? titleColor,
    bool showArrow = true,
  }) {
    final isAr = AppLocalizations.of(context).isAr;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.2)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
        ),
        title: Text(title, style: TextStyle(color: titleColor ?? Theme.of(context).colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w600)),
        subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12)) : null,
        trailing: showArrow ? Icon(isAr ? Icons.arrow_back_ios : Icons.arrow_forward_ios, color: Theme.of(context).colorScheme.outline, size: 14) : null,
      ),
    );
  }
}
