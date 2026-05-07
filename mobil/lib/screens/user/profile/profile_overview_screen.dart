import 'package:flutter/material.dart';
import '../../../shared/l10n/app_localizations.dart';
import '../../../app/router/app_router.dart';
import 'profile_media_edit_screen.dart';
import '../notifications/notifications_screen.dart';
import '../settings/setting_screen.dart';
import '../../../shared/state/recruitment_sync_store.dart';
import '../../../shared/utils/image_helper.dart';

class ProfileOverviewScreen extends StatefulWidget {
  const ProfileOverviewScreen({super.key});

  @override
  State<ProfileOverviewScreen> createState() => _ProfileOverviewScreenState();
}

class _ProfileOverviewScreenState extends State<ProfileOverviewScreen> {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final store = RecruitmentSyncStore.instance;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: store,
          builder: (context, _) {
            // تحديد مسمى الحالة بناءً على دور المستخدم
            final String statusLabel = store.userRole == 'Tradesman' 
                ? t.tr(en: "Tradesman", ar: "صنايعي")
                : t.tr(en: "Job Seeker", ar: "باحث عن عمل");

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar Icons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildTopIconButton(
                          Icons.notifications_none,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildTopIconButton(
                          Icons.settings_outlined,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SettingScreen()),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Cover Image & Profile Pic
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: Theme.of(context).brightness == Brightness.dark 
                                ? [const Color(0xFF321A2C), const Color(0xFF0F0F10)]
                                : [const Color(0xFFE3EAF2), const Color(0xFFF9FBFE)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ProfileMediaEditScreen()),
                                );
                                setState(() {});
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(Icons.edit_note, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -40,
                        left: 20,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark 
                                ? const Color(0xFF001E3A) 
                                : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 2,
                              )
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: getAppImageProvider(store.profileImage),
                            child: store.profileImage == null 
                                ? const Icon(Icons.person, size: 45, color: Colors.grey) 
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 50),

                  // User Info Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (!isAr) ...[
                              _buildEditButton(context, t),
                              const SizedBox(width: 12),
                            ],
                            
                            Expanded(
                              child: Text(
                                store.currentUserName.isEmpty ? t.notYet : store.currentUserName,
                                textAlign: isAr ? TextAlign.right : TextAlign.left,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface, 
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            
                            if (isAr) ...[
                              const SizedBox(width: 12),
                              _buildEditButton(context, t),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        // عرض الحالة (باحث عن عمل / صنايعي)
                        Text(
                          statusLabel,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // عرض العنوان تحت الحالة مباشرة
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54), size: 16),
                            const SizedBox(width: 4),
                            Text(
                              store.currentUserLocation.isEmpty ? t.notYet : store.currentUserLocation, 
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54), fontSize: 14)
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Opportunities Badge
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.teal.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.flag_outlined, color: Colors.teal, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            t.tr(en: "OPEN FOR OPPORTUNITIES", ar: "متاح للفرص"),
                            style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.tealAccent : Colors.teal, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Details Section with Dividers
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.additionalDetails, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        _buildDetailItem(context, Icons.email_outlined, t.email, store.currentUserEmail),
                        const Divider(height: 1, thickness: 0.5),
                        const SizedBox(height: 15),
                        _buildDetailItem(context, Icons.phone_android_outlined, t.phone, store.currentUserPhone),
                        const Divider(height: 1, thickness: 0.5),
                        const SizedBox(height: 15),
                        _buildDetailItem(context, Icons.location_on_outlined, t.address, store.currentUserLocation),
                        const Divider(height: 1, thickness: 0.5),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  _buildSectionTitle(t.aboutMeSection),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store.currentUserAbout.isEmpty ? t.notYet : store.currentUserAbout,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 14, height: 1.5),
                        ),
                        const SizedBox(height: 15),
                        Divider(color: Theme.of(context).dividerColor.withOpacity(0.12), height: 1),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildSectionTitle(t.workExperience),
                  if (store.currentUserExperience.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(t.notYet, style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                    )
                  else
                    ...store.currentUserExperience.map((exp) => _buildEntryItem(
                      Icons.work_outline,
                      exp['title'] ?? "", 
                      exp['company'] ?? "", 
                      exp['duration'] ?? ""
                    )),

                  const SizedBox(height: 30),

                  _buildSectionTitle(t.education),
                  if (store.currentUserEducation.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(t.notYet, style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                    )
                  else
                    ...store.currentUserEducation.map((edu) => _buildEntryItem(
                      Icons.school_outlined,
                      edu['institution'] ?? "", 
                      edu['degree'] ?? "", 
                      edu['duration'] ?? ""
                    )),

                  const SizedBox(height: 30),

                  _buildSectionTitle(t.skills),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: store.currentUserSkills.isEmpty
                        ? Text(t.notYet, style: TextStyle(color: Colors.grey.shade400, fontSize: 12))
                        : Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: store.currentUserSkills.map((skill) => _buildSkillTag(skill)).toList(),
                          ),
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEditButton(BuildContext context, AppLocalizations t) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.userEditProfile),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF007BFF), 
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF007BFF).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.edit, color: Colors.white, size: 14),
            const SizedBox(width: 6),
            Text(
              t.editProfile, 
              style: const TextStyle(
                color: Colors.white, 
                fontSize: 12, 
                fontWeight: FontWeight.bold
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopIconButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark 
              ? const Color(0xFF0D2D4D) 
              : Theme.of(context).colorScheme.primary.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.12)),
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.onSurface, size: 22),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Text(
        title,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEntryItem(IconData icon, String title, String subtitle, String duration) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("$subtitle • $duration", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54), fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 13),
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, IconData icon, String title, String value) {
    final t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? t.notYet : value, 
                  style: TextStyle(
                    color: value.isEmpty 
                        ? Theme.of(context).colorScheme.onSurface.withOpacity(0.38)
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                    fontSize: 13
                  ), 
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
