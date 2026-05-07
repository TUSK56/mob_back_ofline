import 'package:flutter/material.dart';
import '../../../shared/l10n/app_localizations.dart';
import '../../../shared/state/recruitment_sync_store.dart';
import '../../../shared/utils/image_helper.dart';
import 'user_data.dart';

class ProfileMediaEditScreen extends StatefulWidget {
  const ProfileMediaEditScreen({super.key});

  @override
  State<ProfileMediaEditScreen> createState() => _ProfileMediaEditScreenState();
}

class _ProfileMediaEditScreenState extends State<ProfileMediaEditScreen> {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final store = RecruitmentSyncStore.instance;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.tr(en: "Edit Profile Media", ar: "تعديل صور الحساب")),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image Section
            Text(
              t.tr(en: "Cover Photo", ar: "صورة الغلاف"),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                // Here you would typically use an image picker
                // For now, we'll just simulate selecting one
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t.tr(en: "Image picker will open", ar: "سيفتح معرض الصور"))),
                );
              },
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  image: UserProfileData.coverImage != null
                      ? DecorationImage(
                          image: NetworkImage(UserProfileData.coverImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_outlined, size: 40, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 8),
                      Text(
                        t.tr(en: "Tap to change cover photo", ar: "اضغط لتغيير صورة الغلاف"),
                        style: TextStyle(color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Profile Image Section
            Text(
              t.tr(en: "Profile Photo", ar: "الصورة الشخصية"),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Center(
              child: ListenableBuilder(
                listenable: store,
                builder: (context, _) {
                  final p = getAppImageProvider(store.profileImage);
                  return Stack(
                    children: [
                      CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: p,
                        child: p == null ? const Icon(Icons.person, size: 70, color: Colors.grey) : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(t.tr(en: "Image picker will open", ar: "سيفتح معرض الصور"))),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.edit, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 50),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Save logic would go here
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  t.tr(en: "Save Changes", ar: "حفظ التغييرات"),
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
