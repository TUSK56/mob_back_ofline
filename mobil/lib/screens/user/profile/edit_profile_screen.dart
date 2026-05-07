import 'package:flutter/material.dart';
import '../../../shared/l10n/app_localizations.dart';
import 'profile_login_details_screen.dart';
import 'setting_profile/notifications.dart';
import 'setting_profile/preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../../../shared/utils/image_helper.dart';
import '../../../shared/services/recruitment_sync_service.dart';
import '../../../shared/state/recruitment_sync_store.dart';
import 'user_data.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _aboutMeController;
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _dobController;
  late TextEditingController _locationController;
  late TextEditingController _industryController;
  late TextEditingController _skillController;
  
  // Use fixed keys for logic: 'Male' or 'Female'
  String _selectedGender = "Male";

  late List<Map<String, String>> _experiences;
  late List<Map<String, String>> _education;
  late List<String> _skills;
  late List<Map<String, String>> _socialLinks;
  late List<String> _portfolioImages;

  @override
  void initState() {
    super.initState();

    _aboutMeController = TextEditingController(text: UserProfileData.aboutMe);
    _fullNameController = TextEditingController(text: UserProfileData.fullName);
    _phoneController = TextEditingController(text: UserProfileData.phone);
    _emailController = TextEditingController(text: UserProfileData.email);
    _dobController = TextEditingController(text: UserProfileData.dob);
    _locationController = TextEditingController(text: UserProfileData.location);
    _industryController = TextEditingController(text: RecruitmentSyncStore.instance.currentUserIndustry);
    _skillController = TextEditingController();
    
    // Normalize gender value
    if (UserProfileData.gender == "ذكر" || UserProfileData.gender == "Male") {
      _selectedGender = "Male";
    } else if (UserProfileData.gender == "أنثى" || UserProfileData.gender == "Female") {
      _selectedGender = "Female";
    } else {
      _selectedGender = "Male";
    }

    _experiences = List.from(UserProfileData.experiences);
    _education = List.from(UserProfileData.education);
    _skills = List.from(UserProfileData.skills);
    _socialLinks = List.from(UserProfileData.socialLinks);
    _portfolioImages = List.from(UserProfileData.portfolioImages);
  }

  @override
  void dispose() {
    _aboutMeController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _locationController.dispose();
    _industryController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  void _saveData() {
    final t = AppLocalizations.of(context);
    setState(() {
      UserProfileData.fullName = _fullNameController.text;
      UserProfileData.phone = _phoneController.text;
      UserProfileData.email = _emailController.text;
      UserProfileData.dob = _dobController.text;
      UserProfileData.location = _locationController.text;
      // Save translated value or key as needed
      UserProfileData.gender = _selectedGender == "Male" ? t.male : t.female;
      UserProfileData.aboutMe = _aboutMeController.text;

      UserProfileData.experiences = List.from(_experiences);
      UserProfileData.education = List.from(_education);
      UserProfileData.skills = List.from(_skills);
      UserProfileData.socialLinks = List.from(_socialLinks);
      UserProfileData.portfolioImages = List.from(_portfolioImages);
    });

    // Sync with backend
    RecruitmentSyncService.instance.updateProfile(
      name: _fullNameController.text,
      industry: _industryController.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t.tr(en: "Saved successfully", ar: "تم الحفظ بنجاح")),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
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
          crossAxisAlignment: t.isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTabItem(t.tr(en: "Profile Setting", ar: "إعدادات الملف"), true, () {}),
                  const SizedBox(width: 20),
                  _buildTabItem(t.tr(en: "Account Security", ar: "أمان الحساب"), false, () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfileLoginDetailsScreen()));
                  }),
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
            Divider(color: Theme.of(context).dividerColor.withOpacity(0.12), height: 1),
            const SizedBox(height: 30),

            // Basic Information
            Text(t.tr(en: "Basic Information", ar: "معلومات أساسية"), style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(t.tr(en: "This is your personal information that you can update anytime.", ar: "هذه هي معلوماتك الشخصية التي يمكنك تحديثها في أي وقت."), style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54), fontSize: 13)),
            Divider(color: Theme.of(context).dividerColor.withOpacity(0.12), height: 40),

            // Profile Photo
            Text(t.tr(en: "Profile Photo", ar: "صورة الملف الشخصي"), style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.grey.withOpacity(0.1),
                    backgroundImage: getAppImageProvider(UserProfileData.profileImage),
                    child: UserProfileData.profileImage == null 
                        ? Icon(Icons.camera_alt, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)) 
                        : null,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.12)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.image_outlined, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38), size: 30),
                          const SizedBox(height: 8),
                          Text(t.tr(en: "Click to replace or drag and drop", ar: "انقر للاستبدال أو السحب والإفلات"), style: const TextStyle(color: Colors.blueAccent, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: Theme.of(context).dividerColor.withOpacity(0.12), height: 40),

            // Personal Details
            Text(t.tr(en: "Personal Details", ar: "تفاصيل شخصية"), style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildTextFieldWithLabel(_fullNameController, t.tr(en: "Full Name", ar: "الاسم بالكامل"), t.tr(en: "Enter Full Name", ar: "أدخل الاسم بالكامل"))),
                const SizedBox(width: 15),
                Expanded(child: _buildTextFieldWithLabel(_phoneController, t.tr(en: "Phone Number", ar: "رقم الهاتف"), t.tr(en: "Enter Phone Number", ar: "أدخل رقم الهاتف"))),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildTextFieldWithLabel(_emailController, t.tr(en: "Email", ar: "البريد الإلكتروني"), t.tr(en: "Enter Email", ar: "أدخل البريد الإلكتروني"))),
                const SizedBox(width: 15),
                Expanded(child: _buildTextFieldWithLabel(_dobController, t.dob, t.tr(en: "Enter Date of Birth", ar: "أدخل تاريخ الميلاد"), suffixIcon: Icons.calendar_today_outlined)),
              ],
            ),
            const SizedBox(height: 20),
            _buildTextFieldWithLabel(_locationController, t.address, t.tr(en: "Enter Address", ar: "أدخل العنوان"), suffixIcon: Icons.location_on_outlined),
            const SizedBox(height: 20),
            _buildTextFieldWithLabel(_industryController, t.industry, t.tr(en: "Enter Classification", ar: "أدخل التصنيف"), suffixIcon: Icons.work_outline),
            const SizedBox(height: 20),
            
            // Gender Dropdown
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: t.gender,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
                    children: const [TextSpan(text: " *", style: TextStyle(color: Colors.red))],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 150,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white.withOpacity(0.05) 
                        : Colors.black.withOpacity(0.05),
                    border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.12)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedGender,
                      items: [
                        DropdownMenuItem(value: "Male", child: Text(t.male)),
                        DropdownMenuItem(value: "Female", child: Text(t.female)),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedGender = val);
                      },
                    ),
                  ),
                ),
              ],
            ),
            
            Divider(color: Theme.of(context).dividerColor.withOpacity(0.12), height: 40),

            // Criminal Record Certificate
            Text(t.tr(en: "Criminal Record Certificate", ar: "فيش وتشبيه"), style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.12)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.cloud_upload_outlined, color: Theme.of(context).colorScheme.primary, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        UserProfileData.cvName ?? t.tr(en: "Upload Certificate", ar: "رفع الشهادة"),
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Divider(color: Theme.of(context).dividerColor.withOpacity(0.12), height: 40),

            // About Me
            Text(t.aboutMe, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildTextField(_aboutMeController, t.tr(en: "Enter About Me", ar: "أدخل معلومات عنك"), maxLines: 3),
            Divider(color: Theme.of(context).dividerColor.withOpacity(0.12), height: 40),

            // Sections (Experiences, Education, Skills, etc.)
            _buildSectionHeader(t.workExperience, () {
               _showAddItemDialog(title: t.tr(en: "Add Experience", ar: "إضافة خبرة"), fieldLabels: ["Title", "Company", "Duration"], onSave: (data) => setState(() => _experiences.add(data)));
            }),
            ..._experiences.map((exp) => _buildRemovableItem(exp['title'] ?? "", exp['company'] ?? "", () => setState(() => _experiences.remove(exp)))),
            Divider(color: Theme.of(context).dividerColor.withOpacity(0.12), height: 40),

            _buildSectionHeader(t.education, () {
               _showAddItemDialog(title: t.tr(en: "Add Education", ar: "إضافة تعليم"), fieldLabels: ["Institution", "Degree", "Duration"], onSave: (data) => setState(() => _education.add(data)));
            }),
            ..._education.map((edu) => _buildRemovableItem(edu['institution'] ?? "", edu['degree'] ?? "", () => setState(() => _education.remove(edu)))),
            Divider(color: Theme.of(context).dividerColor.withOpacity(0.12), height: 40),

            // Skills
            Text(t.skills, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _skills.map((skill) => Chip(label: Text(skill, style: const TextStyle(fontSize: 12)), onDeleted: () => setState(() => _skills.remove(skill)))).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildTextField(_skillController, t.tr(en: "Add Skill", ar: "إضافة مهارة"))),
                IconButton(icon: const Icon(Icons.add_circle, color: Colors.blueAccent), onPressed: () {
                  if (_skillController.text.isNotEmpty) { setState(() { _skills.add(_skillController.text); _skillController.clear(); }); }
                }),
              ],
            ),
            Divider(color: Theme.of(context).dividerColor.withOpacity(0.12), height: 40),

            // Social Media
            _buildSectionHeader(t.socialMedia, () {
               _showAddItemDialog(title: t.tr(en: "Add Social Link", ar: "إضافة رابط تواصل"), fieldLabels: ["Platform", "URL"], onSave: (data) => setState(() => _socialLinks.add(data)));
            }),
            ..._socialLinks.map((link) => _buildRemovableItem(link['platform'] ?? "", link['url'] ?? "", () => setState(() => _socialLinks.remove(link)))),
            Divider(color: Theme.of(context).dividerColor.withOpacity(0.12), height: 40),

            const SizedBox(height: 40),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _saveData,
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                child: Text(t.tr(en: "Save Profile", ar: "حفظ الملف الشخصي"), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  void _showAddItemDialog({required String title, required List<String> fieldLabels, required Function(Map<String, String>) onSave}) {
    final controllers = fieldLabels.map((_) => TextEditingController()).toList();
    showDialog(context: context, builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(mainAxisSize: MainAxisSize.min, children: List.generate(fieldLabels.length, (index) => Padding(padding: const EdgeInsets.only(bottom: 10), child: TextField(controller: controllers[index], decoration: InputDecoration(labelText: fieldLabels[index], border: const OutlineInputBorder()))))),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")), ElevatedButton(onPressed: () {
          final data = <String, String>{};
          for (int i = 0; i < fieldLabels.length; i++) { data[fieldLabels[i].toLowerCase()] = controllers[i].text; }
          onSave(data); Navigator.pop(context);
        }, child: const Text("Add"))],
    ));
  }

  Future<void> _pickImage() async {
    final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50, maxWidth: 500, maxHeight: 500);
    if (image != null) {
      try {
        final bytes = await image.readAsBytes();
        final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        
        setState(() { UserProfileData.profileImage = base64Image; });
        await RecruitmentSyncService.instance.updateProfile(photoUrl: base64Image);
      } catch (_) {}
    }
  }

  Widget _buildSectionHeader(String title, VoidCallback onAdd) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold)), IconButton(icon: const Icon(Icons.add_circle_outline, color: Colors.blueAccent), onPressed: onAdd)]);

  Widget _buildRemovableItem(String title, String subtitle, VoidCallback onDelete) => ListTile(contentPadding: EdgeInsets.zero, title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)), subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)), trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20), onPressed: onDelete));

  Widget _buildTabItem(String title, bool isActive, VoidCallback onTap) => GestureDetector(onTap: onTap, child: Column(children: [Text(title, style: TextStyle(color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.38), fontWeight: isActive ? FontWeight.bold : FontWeight.normal, fontSize: 14)), if (isActive) Container(margin: const EdgeInsets.only(top: 8), height: 2, width: 60, color: Theme.of(context).colorScheme.primary)]));

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) => TextField(controller: controller, maxLines: maxLines, style: TextStyle(color: Theme.of(context).colorScheme.onSurface), decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38)), filled: true, fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05), border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.12))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.12)))));

  Widget _buildTextFieldWithLabel(TextEditingController controller,
      String label, String hint,
      {IconData? suffixIcon}) => Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [RichText(
      text: TextSpan(text: label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
      children:
      const [TextSpan(text: " *", style: TextStyle(color: Colors.red))])),
  const SizedBox(height: 8),
  TextField(controller: controller, style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
  decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38), fontSize: 12),
  suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54), size: 18) : null,
  filled: true, fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(4),
  borderSide: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.12))),
  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4),
  borderSide: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.12))
  )
  )
  )
      ]
  );
}
