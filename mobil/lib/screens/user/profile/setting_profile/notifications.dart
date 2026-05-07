import 'package:flutter/material.dart';
import '../../../../shared/l10n/app_localizations.dart';
import '../edit_profile_screen.dart';
import '../profile_login_details_screen.dart';
import 'preferences.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  bool _emailEnabled = true;
  bool _jobsEnabled = true;
  bool _updatesEnabled = false;

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
                  _buildTabItem(t.tr(en: "Account Security", ar: "أمان الحساب"), false, () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfileLoginDetailsScreen()));
                  }),
                  const SizedBox(width: 20),
                  _buildTabItem(t.tr(en: "Notification", ar: "الإشعارات"), true, () {}),
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

            // Notification Settings Title
            Text(t.tr(en: "Notification Settings", ar: "إعدادات الإشعارات"), style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(t.tr(en: "Choose how and when you want to receive notifications from us.", ar: "اختر كيف ومتى تود استلام الإشعارات منا."), style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 13)),
            const SizedBox(height: 40),

            _buildNotificationOption(
              t.tr(en: "Email Notifications", ar: "إشعارات البريد الإلكتروني"),
              t.tr(en: "Receive weekly summary for jobs and articles", ar: "استلم ملخصاً أسبوعياً للوظائف والمقالات"),
              _emailEnabled,
              (val) => setState(() => _emailEnabled = val),
            ),
            _buildNotificationOption(
              t.tr(en: "Job Alerts", ar: "تنبيهات الوظائف"),
              t.tr(en: "When new jobs that match your skills are posted", ar: "عند نشر وظيفة جديدة تناسب مهاراتك"),
              _jobsEnabled,
              (val) => setState(() => _jobsEnabled = val),
            ),
            _buildNotificationOption(
              t.tr(en: "Application Updates", ar: "تحديثات الطلبات"),
              t.tr(en: "When your application status changes", ar: "عند تغير حالة طلبات التوظيف الخاصة بك"),
              _updatesEnabled,
              (val) => setState(() => _updatesEnabled = val),
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
                      const SnackBar(content: Text("Notification Settings Saved!")),
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
              color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), 
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

  Widget _buildNotificationOption(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 13)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: Theme.of(context).colorScheme.primary,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Theme.of(context).colorScheme.outlineVariant,
          ),
        ],
      ),
    );
  }
}

