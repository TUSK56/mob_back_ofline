import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/router/app_router.dart';
import '../../../../shared/l10n/app_localizations.dart';
import '../../../../shared/services/recruitment_sync_service.dart';
import '../../../../shared/services/session_manager.dart';
import '../../profile/user_data.dart';
import 'sign_up_tradesman.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final String _selectedRole = "Job Seeker";

  // Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _aboutMeController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _socialController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  // DOB Dropdowns
  String? _selectedDay;
  String? _selectedMonth;
  String? _selectedYear;
  final List<String> _days = List.generate(31, (i) => (i + 1).toString().padLeft(2, '0'));
  final List<String> _months = List.generate(12, (i) => (i + 1).toString().padLeft(2, '0'));
  final List<String> _years = List.generate(70, (i) => (DateTime.now().year - 10 - i).toString());

  String? _selectedGender;

  // Education Controllers
  final TextEditingController _eduInstitutionController = TextEditingController();
  final TextEditingController _eduDegreeController = TextEditingController();
  final TextEditingController _eduDurationController = TextEditingController();

  // Experience Controllers
  final TextEditingController _expJobTitleController = TextEditingController();
  final TextEditingController _expDurationController = TextEditingController();

  final List<String> _skillsList = [];
  final List<Map<String, String>> _socialLinksList = [];
  final List<Map<String, String>> _experiencesList = [];
  final List<Map<String, String>> _educationList = [];

  String? _profileImagePath;
  final List<String> _platforms = ["LinkedIn", "GitHub", "Twitter", "Instagram", "Facebook", "Other"];
  String _selectedPlatform = "LinkedIn";

  Future<void> _pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImagePath = image.path;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _aboutMeController.dispose();
    _skillsController.dispose();
    _socialController.dispose();
    _eduInstitutionController.dispose();
    _eduDegreeController.dispose();
    _eduDurationController.dispose();
    _expJobTitleController.dispose();
    _expDurationController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _addEducation() {
    if (_eduInstitutionController.text.isNotEmpty && _eduDegreeController.text.isNotEmpty) {
      setState(() {
        _educationList.add({
          "institution": _eduInstitutionController.text.trim(),
          "degree": _eduDegreeController.text.trim(),
          "duration": _eduDurationController.text.trim(),
        });
        _eduInstitutionController.clear();
        _eduDegreeController.clear();
        _eduDurationController.clear();
      });
    }
  }

  void _addExperience() {
    if (_expJobTitleController.text.isNotEmpty) {
      setState(() {
        _experiencesList.add({
          "title": _expJobTitleController.text.trim(),
          "duration": _expDurationController.text.trim(),
        });
        _expJobTitleController.clear();
        _expDurationController.clear();
      });
    }
  }

  void _addSkill() {
    String skill = _skillsController.text.trim();
    if (skill.isNotEmpty && !_skillsList.contains(skill)) {
      setState(() {
        _skillsList.add(skill);
        _skillsController.clear();
      });
    }
  }

  void _addSocialLink() {
    if (_socialController.text.isNotEmpty) {
      setState(() {
        _socialLinksList.add({"platform": _selectedPlatform, "url": _socialController.text.trim()});
        _socialController.clear();
      });
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDay == null || _selectedMonth == null || _selectedYear == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select your full Date of Birth")));
        return;
      }
      if (_selectedGender == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select gender")));
        return;
      }
      if (_passwordController.text.length < 8) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password must be at least 8 characters")));
        return;
      }
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
        return;
      }

      setState(() => _isLoading = true);
      try {
        final role = _selectedRole == "Tradesman" ? "tradesman" : "user";
        await RecruitmentSyncService.instance.register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _fullNameController.text.trim(),
          role: role,
        );

        await SessionManager.saveUserSession(
          email: _emailController.text.trim(),
          name: _fullNameController.text.trim(),
        );

        String? base64Image;
        if (_profileImagePath != null) {
          try {
            final bytes = await File(_profileImagePath!).readAsBytes();
            base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
          } catch (_) {}
        }

        // Send all profile data to the backend
        await RecruitmentSyncService.instance.updateProfile(
          photoUrl: base64Image,
          phone: _phoneController.text.trim(),
          gender: _selectedGender,
          dob: "$_selectedYear-$_selectedMonth-$_selectedDay",
          address: _addressController.text.trim(),
          about: _aboutMeController.text.trim(),
          title: _expJobTitleController.text.isNotEmpty ? _expJobTitleController.text : "User",
          skills: _skillsList,
          educationJson: jsonEncode(_educationList),
          experienceJson: jsonEncode(_experiencesList),
          socialLinksJson: jsonEncode(_socialLinksList),
        );

        UserProfileData.fullName = _fullNameController.text;
        UserProfileData.email = _emailController.text;
        UserProfileData.phone = "+20 ${_phoneController.text}";
        UserProfileData.aboutMe = _aboutMeController.text;
        UserProfileData.dob = "$_selectedYear-$_selectedMonth-$_selectedDay";
        UserProfileData.location = _addressController.text;
        UserProfileData.gender = _selectedGender!;
        UserProfileData.skills = List.from(_skillsList);
        UserProfileData.socialLinks = List.from(_socialLinksList);
        UserProfileData.experiences = List.from(_experiencesList);
        UserProfileData.profileImage = _profileImagePath;

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile saved successfully!")));
        setState(() => _isLoading = false);
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.userWorkspace,
          (route) => false,
        );
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registration failed: ${e.toString()}")),
        );
      }
    }
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
          t.isAr ? "إنشاء حساب" : "Sign Up",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(text: t.isAr ? "يمكنك " : "You Can "),
                      TextSpan(
                        text: t.isAr ? "التسجيل " : "SignUp ",
                        style: const TextStyle(color: Color(0xFF49769F)),
                      ),
                      TextSpan(
                        text: t.isAr
                            ? "كحرفي أو باحث عن عمل"
                            : "Tradesman or a job seeker",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Container(width: 80, height: 3, color: Colors.orange, margin: const EdgeInsets.only(left: 230)),
                const SizedBox(height: 25),
                
                // Role selection with lines
                Row(
                  children: [
                    Expanded(child: _buildRoleOption("Job Seeker")),
                    const SizedBox(width: 8),
                    Text(t.tr(en: "or", ar: "أو"), style: const TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildRoleOption("Tradesman")),
                  ],
                ),
                const SizedBox(height: 35),

                // Profile Image Avatar Preview (Moved to the left)
                GestureDetector(
                  onTap: _pickProfileImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).cardColor,
                    backgroundImage: _profileImagePath != null 
                        ? FileImage(File(_profileImagePath!))
                        : null,
                    child: _profileImagePath == null
                        ? const Icon(Icons.person, size: 50, color: Color(0xFF49769F))
                        : null,
                  ),
                ),
                const SizedBox(height: 20),

                Text(t.personalInfo, style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 20),
                _buildTextField(_fullNameController, t.fullName, Icons.person_outline, isRequired: true),
                const SizedBox(height: 20),
                _buildTextField(_emailController, t.emailAddress, Icons.email_outlined, isRequired: true, validator: (v) => (v == null || !v.endsWith("@gmail.com")) ? t.enterValidEmail : null),
                const SizedBox(height: 20),
                _buildTextField(_phoneController, t.phoneNumber, Icons.phone_android_outlined, keyboardType: TextInputType.phone, isRequired: true, prefixText: "+20 ", inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)]),
                const SizedBox(height: 20),
                
                // Gender Dropdown
                _buildDropdownField(
                  label: t.gender,
                  icon: Icons.person_search_outlined,
                  value: _selectedGender,
                  items: [t.tr(en: 'Male', ar: 'ذكر'), t.tr(en: 'Female', ar: 'أنثى')],
                  onChanged: (v) => setState(() => _selectedGender = v),
                  isRequired: true,
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  _passwordController, 
                  t.password, 
                  Icons.lock_outline, 
                  isRequired: true, 
                  obscureText: _obscurePassword,
                  suffixIcon: _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  onSuffixTap: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  _confirmPasswordController, 
                  t.confirmPassword, 
                  Icons.lock_reset, 
                  isRequired: true, 
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                  onSuffixTap: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
                const SizedBox(height: 20),

                // Date of Birth Dropdowns (Matching Tradesman)
                Text(t.dob, style: const TextStyle(color: Colors.black54, fontSize: 14)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildSimpleDropdown(t.day, _days, _selectedDay, (v) => setState(() => _selectedDay = v))),
                    const SizedBox(width: 10),
                    Expanded(child: _buildSimpleDropdown(t.month, _months, _selectedMonth, (v) => setState(() => _selectedMonth = v))),
                    const SizedBox(width: 10),
                    Expanded(child: _buildSimpleDropdown(t.year, _years, _selectedYear, (v) => setState(() => _selectedYear = v))),
                  ],
                ),
                const SizedBox(height: 20),
                
                _buildTextField(_addressController, t.address, Icons.location_on_outlined, isRequired: true),

                const SizedBox(height: 35),
                Text(t.education, style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600)),
                Text(t.tr(en: "Add your academic qualifications", ar: "أضف مؤهلاتك الأكاديمية"), style: const TextStyle(color: Colors.black38, fontSize: 12)),
                const SizedBox(height: 20),
                _buildTextField(_eduInstitutionController, t.tr(en: "Education Institution", ar: "المؤسسة التعليمية"), Icons.school_outlined),
                const SizedBox(height: 15),
                _buildTextField(_eduDegreeController, t.tr(en: "Academic Degree", ar: "الدرجة العلمية"), Icons.workspace_premium_outlined),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_eduDurationController, t.tr(en: "Duration", ar: "المدة"), Icons.timer_outlined)),
                    const SizedBox(width: 10),
                    IconButton(onPressed: _addEducation, icon: const Icon(Icons.add_circle, color: Color(0xFF49769F), size: 35)),
                  ],
                ),
                ..._educationList.asMap().entries.map((entry) => Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
                  child: Row(
                    children: [
                      const Icon(Icons.book, color: Color(0xFF49769F), size: 20),
                      const SizedBox(width: 12),
                      Expanded(child: Text("${entry.value['institution']} - ${entry.value['degree']} (${entry.value['duration']})", style: const TextStyle(color: Colors.black87, fontSize: 12))),
                      IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20), onPressed: () => setState(() => _educationList.removeAt(entry.key))),
                    ],
                  ),
                )).toList(),

                const SizedBox(height: 35),
                Text(t.tr(en: "Professional Details", ar: "تفاصيل مهنية"), style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 20),
                _buildTextField(_aboutMeController, t.aboutMe, Icons.info_outline, maxLines: 3),

                const SizedBox(height: 25),
                Text(t.expWork, style: const TextStyle(color: Colors.black54, fontSize: 14)),
                const SizedBox(height: 10),
                _buildTextField(_expJobTitleController, t.tr(en: "Job Title", ar: "المسمى الوظيفي"), Icons.title),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_expDurationController, t.tr(en: "Duration", ar: "المدة"), Icons.timer)),
                    const SizedBox(width: 10),
                    IconButton(onPressed: _addExperience, icon: const Icon(Icons.add_circle, color: Color(0xFF49769F), size: 35)),
                  ],
                ),
                ..._experiencesList.asMap().entries.map((entry) => Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
                  child: Row(
                    children: [
                      const Icon(Icons.work_history, color: Color(0xFF49769F), size: 20),
                      const SizedBox(width: 12),
                      Expanded(child: Text("${entry.value['title']} (${entry.value['duration']})", style: const TextStyle(color: Colors.black87, fontSize: 12))),
                      IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20), onPressed: () => setState(() => _experiencesList.removeAt(entry.key))),
                    ],
                  ),
                )).toList(),

                const SizedBox(height: 25),
                Text(t.tr(en: "Skills", ar: "المهارات"), style: const TextStyle(color: Colors.black54, fontSize: 14)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _skillsController,
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: t.tr(en: "Type and press Add", ar: "اكتب واضغط إضافة"), 
                    hintStyle: const TextStyle(color: Colors.black26, fontSize: 12),
                    prefixIcon: const Icon(Icons.star_outline, color: Color(0xFF49769F), size: 20),
                    suffixIcon: IconButton(icon: const Icon(Icons.add_circle_outline, color: Color(0xFF49769F)), onPressed: _addSkill),
                    filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade300)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF49769F))),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8, children: _skillsList.map((s) => Chip(label: Text(s, style: const TextStyle(color: Colors.black87, fontSize: 11)), backgroundColor: const Color(0xFF49769F).withOpacity(0.1), onDeleted: () => setState(() => _skillsList.remove(s)), deleteIcon: const Icon(Icons.close, size: 14, color: Colors.black54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))).toList()),

                const SizedBox(height: 25),
                Text(t.socialLinks, style: const TextStyle(color: Colors.black54, fontSize: 14)),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(flex: 3, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade300)), child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: _selectedPlatform, dropdownColor: Colors.white, isExpanded: true, style: const TextStyle(color: Colors.black87, fontSize: 12), items: _platforms.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => _selectedPlatform = v!))))),
                  const SizedBox(width: 10),
                  Expanded(flex: 5, child: TextFormField(controller: _socialController, style: const TextStyle(color: Colors.black87, fontSize: 13), decoration: InputDecoration(hintText: t.tr(en: "Link", ar: "الرابط"), hintStyle: const TextStyle(color: Colors.black26, fontSize: 12), filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.all(16), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade300))))),
                  IconButton(onPressed: _addSocialLink, icon: const Icon(Icons.add_circle, color: Color(0xFF49769F), size: 30)),
                ]),
                const SizedBox(height: 10),
                ..._socialLinksList.asMap().entries.map((entry) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)), child: Row(children: [const Icon(Icons.link, color: Color(0xFF49769F), size: 18), const SizedBox(width: 12), Expanded(child: Text("${entry.value['platform']}: ${entry.value['url']}", style: const TextStyle(color: Colors.black87, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis)), IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20), onPressed: () => setState(() => _socialLinksList.removeAt(entry.key)))]))).toList(),

                const SizedBox(height: 40),
                SizedBox(width: double.infinity, height: 56, child: ElevatedButton(onPressed: _isLoading ? null : _saveProfile, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF49769F), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(t.saveProfile, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)))),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption(String role) {
    final t = AppLocalizations.of(context);
    String displayLabel = role;
    if (role == "Job Seeker") {
      displayLabel = t.tr(en: "Job Seeker", ar: "باحث عن عمل");
    } else if (role == "Tradesman") {
      displayLabel = t.tr(en: "Tradesman", ar: "حرفي");
    }
    
    bool isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () {
        if (role == "Tradesman") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SignUpTradesman()),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF49769F) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? const Color(0xFF49769F) : Colors.grey.shade300, width: 1.5),
          boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF49769F).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
        ),
        alignment: Alignment.center,
        child: Text(
          displayLabel,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {String? hint, String? prefixText, int maxLines = 1, TextInputType keyboardType = TextInputType.text, bool isRequired = false, VoidCallback? onIconTap, IconData? suffixIcon, VoidCallback? onSuffixTap, List<TextInputFormatter>? inputFormatters, String? Function(String?)? validator, bool readOnly = false, bool obscureText = false}) {
    return TextFormField(
      controller: controller, maxLines: maxLines, keyboardType: keyboardType, inputFormatters: inputFormatters, 
      readOnly: readOnly,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black87),
      validator: isRequired ? (validator ?? (value) => (value == null || value.isEmpty) ? "$label is required" : null) : null,
      decoration: InputDecoration(
        prefixText: prefixText, prefixStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        labelText: label, labelStyle: const TextStyle(color: Colors.black54, fontSize: 14),
        hintText: hint, hintStyle: const TextStyle(color: Colors.black26, fontSize: 12),
        prefixIcon: InkWell(onTap: onIconTap, child: Icon(icon, color: const Color(0xFF49769F), size: 20)),
        suffixIcon: suffixIcon != null ? IconButton(icon: Icon(suffixIcon, color: Colors.black54), onPressed: onSuffixTap) : null,
        filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF49769F))),
      ),
    );
  }

  Widget _buildSimpleDropdown(String hint, List<String> items, String? value, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(hint, style: const TextStyle(color: Colors.black26, fontSize: 12)),
          value: value,
          isExpanded: true,
          dropdownColor: Colors.white,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.black87, fontSize: 13)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDropdownField({required String label, required IconData icon, required String? value, required List<String> items, required ValueChanged<String?> onChanged, bool isRequired = false}) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(color: Colors.black87)))).toList(),
      onChanged: onChanged,
      dropdownColor: Colors.white,
      style: const TextStyle(color: Colors.black87),
      validator: isRequired ? (v) => v == null ? "$label is required" : null : null,
      decoration: InputDecoration(
        labelText: label, labelStyle: const TextStyle(color: Colors.black54, fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF49769F), size: 20),
        filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade300)),
      ),
    );
  }
}
