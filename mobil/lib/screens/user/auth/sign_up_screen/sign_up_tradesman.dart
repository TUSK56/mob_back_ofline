import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graduationproject/screens/user/profile/user_data.dart';
import 'package:graduationproject/screens/user/teardsman/nav_Botton_bar/nav_bottom_bar.dart';
import 'package:graduationproject/screens/user/teardsman/profile/teardsman_data.dart';
import 'package:graduationproject/shared/l10n/app_localizations.dart';
import 'package:graduationproject/shared/state/recruitment_sync_store.dart';
import 'package:graduationproject/shared/services/recruitment_sync_service.dart';
import 'package:graduationproject/shared/services/session_manager.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SignUpTradesman extends StatefulWidget {
  const SignUpTradesman({super.key});

  @override
  State<SignUpTradesman> createState() => _SignUpTradesmanState();
}

class _SignUpTradesmanState extends State<SignUpTradesman> {
  final _formKey = GlobalKey<FormState>();
  final String _selectedRole = "Tradesman";

  // Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _aboutMeController = TextEditingController();
  final TextEditingController _serviceController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  
  // Education Controllers
  final TextEditingController _eduInstitutionController = TextEditingController();
  final TextEditingController _eduDegreeController = TextEditingController();
  final TextEditingController _eduDurationController = TextEditingController();

  // Social Controllers
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();


  String? _selectedGender;
  
  // DOB Dropdowns
  String? _selectedDay;
  String? _selectedMonth;
  String? _selectedYear;
  final List<String> _days = List.generate(31, (i) => (i + 1).toString().padLeft(2, '0'));
  final List<String> _months = List.generate(12, (i) => (i + 1).toString().padLeft(2, '0'));
  final List<String> _years = List.generate(70, (i) => (DateTime.now().year - 18 - i).toString());

  // Services
  final List<String> _trades = [
  "فني تكييف","نجار", "فني سباكة", "نقاش (دهانات)", "ميكانيكي", "كهربائي", "حداد", "منظف منازل",
    "فني جبس بورد", "فني سيراميك / بلاط", "فني ألوميتال", "فني زجاج", "فني ستائر", "فني كاميرات مراقبة", "جليسة أطفال", "طباخ منزلي",
    "بستاني", "مكافحة حشرات", "نقل عفش","حارس أمن", "حارس شخصي", "مشرف أمن", "فني أنظمة أمن",
  ];

  final List<Map<String, String>> _educationList = [];
  final List<String> _skillsList = [];
  
  // Criminal record state
  String? _criminalRecordPath;
  String? _profileImagePath;

  Future<void> _pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImagePath = image.path;
      });
    }
  }

  Future<void> _pickCriminalRecord() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
    );
    if (result != null) {
      setState(() {
        _criminalRecordPath = result.files.single.path;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Criminal Record selected successfully")));
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
    _serviceController.dispose();
    _skillsController.dispose();
    _eduInstitutionController.dispose();
    _eduDegreeController.dispose();
    _eduDurationController.dispose();
    _instagramController.dispose();
    _facebookController.dispose();
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

  void _addSkill() {
    String skill = _skillsController.text.trim();
    if (skill.isNotEmpty && !_skillsList.contains(skill)) {
      setState(() {
        _skillsList.add(skill);
        _skillsController.clear();
      });
    }
  }

  void _saveTradesmanProfile() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDay == null || _selectedMonth == null || _selectedYear == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select your full Date of Birth")));
        return;
      }
      if (_selectedGender == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select gender")));
        return;
      }
      if (_criminalRecordPath == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Criminal Record is required")));
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
        await RecruitmentSyncService.instance.register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _fullNameController.text.trim(),
          role: "tradesman",
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
          title: _serviceController.text.isNotEmpty ? _serviceController.text : "Tradesman",
          skills: _skillsList,
          educationJson: jsonEncode(_educationList),
          socialLinksJson: jsonEncode([
            if (_instagramController.text.isNotEmpty) {"platform": "Instagram", "url": _instagramController.text},
            if (_facebookController.text.isNotEmpty) {"platform": "Facebook", "url": _facebookController.text},
          ]),
        );

        TradesmanProfileData.fullName = _fullNameController.text;
        TradesmanProfileData.email = _emailController.text;
        TradesmanProfileData.phone = "+20 ${_phoneController.text}";
        TradesmanProfileData.gender = _selectedGender!;
        TradesmanProfileData.dob = "$_selectedYear-$_selectedMonth-$_selectedDay";
        TradesmanProfileData.address = _addressController.text;
        TradesmanProfileData.aboutMe = _aboutMeController.text;
        TradesmanProfileData.service = _serviceController.text;
        TradesmanProfileData.skills = List.from(_skillsList);
        TradesmanProfileData.education = List.from(_educationList);
        TradesmanProfileData.socialLinks = {
          "instagram": _instagramController.text,
          "facebook": _facebookController.text,
        };
        TradesmanProfileData.criminalRecordUploaded = _criminalRecordPath != null;
        TradesmanProfileData.profileImage = _profileImagePath;
        
        UserProfileData.cvName = _criminalRecordPath != null ? "Criminal_Record_Certificate" : null;

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tradesman Profile saved successfully!")));
        setState(() => _isLoading = false);
        
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Navbotton()),
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
                        style: TextStyle(color: Theme.of(context).colorScheme.primary),
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

                // Role Selection
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

                // Profile Image Avatar Preview (Left aligned)
                GestureDetector(
                  onTap: _pickProfileImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(context).cardColor,
                        backgroundImage: _profileImagePath != null 
                            ? FileImage(File(_profileImagePath!)) as ImageProvider
                            : null,
                        child: _profileImagePath == null
                            ? const Icon(Icons.person, size: 50, color: Color(0xFF49769F))
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Personal Details
                Text(t.personalInfo, style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 20),
                _buildTextField(_fullNameController, t.fullName, Icons.person_outline, isRequired: true),
                const SizedBox(height: 20),
                _buildTextField(_emailController, t.emailAddress, Icons.email_outlined, isRequired: true),
                const SizedBox(height: 20),
                _buildTextField(_phoneController, t.phoneNumber, Icons.phone_android_outlined, 
                  keyboardType: TextInputType.phone, 
                  isRequired: true, 
                  prefixText: "+20 ",
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)]),
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
                
                // Date of Birth Dropdowns
                Text(t.dob, style: const TextStyle(color: Colors.black54, fontSize: 14)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildSimpleDropdown("Day", _days, _selectedDay, (v) => setState(() => _selectedDay = v))),
                    const SizedBox(width: 10),
                    Expanded(child: _buildSimpleDropdown("Month", _months, _selectedMonth, (v) => setState(() => _selectedMonth = v))),
                    const SizedBox(width: 10),
                    Expanded(child: _buildSimpleDropdown("Year", _years, _selectedYear, (v) => setState(() => _selectedYear = v))),
                  ],
                ),
                
                const SizedBox(height: 20),
                _buildTextField(_addressController, t.address, Icons.location_on_outlined, isRequired: true),
                const SizedBox(height: 30),

                // Criminal Record Check (Required)
                Text(
                  t.tr(en: "Criminal Record Certificate", ar: "فيش وتشبيه"),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _buildUploadBox(
                  _criminalRecordPath != null
                      ? "${t.tr(en: 'Criminal Record Certificate', ar: 'فيش وتشبيه')}: ${_criminalRecordPath!.split(Platform.pathSeparator).last} ✓"
                      : t.tr(en: "Upload Criminal Record Certificate", ar: "ارفع فيش وتشبيه"),
                  _pickCriminalRecord,
                ),
                const SizedBox(height: 30),

                // About Me
                Text(t.aboutMe, style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 15),
                _buildTextField(_aboutMeController, t.aboutMe, Icons.info_outline, maxLines: 4),
                const SizedBox(height: 30),

                // Service (Unified Editable Dropdown - Old Look)
                Text("${t.selectService} *", style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600)),
                Text(t.tr(en: "Select from arrow or type your profession", ar: "اختر من السهم أو اكتب مهنتك"), style: const TextStyle(color: Colors.black38, fontSize: 12)),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _serviceController,
                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                  validator: (value) => (value == null || value.isEmpty) ? "${t.selectService} is required" : null,
                  decoration: InputDecoration(
                    labelText: t.selectService,
                    labelStyle: const TextStyle(color: Colors.black54, fontSize: 14),
                    prefixIcon: const Icon(Icons.work_outline, color: Color(0xFF49769F), size: 20),
                    suffixIcon: PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
                      onSelected: (String value) {
                        setState(() {
                          _serviceController.text = value;
                        });
                      },
                      itemBuilder: (BuildContext context) {
                        return _trades.map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice, style: const TextStyle(fontSize: 14)),
                          );
                        }).toList();
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade300)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF49769F))),
                  ),
                ),
                const SizedBox(height: 30),

                // Education
                Text(t.education, style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600)),
                Text(t.tr(en: "Add your academic qualifications", ar: "أضف مؤهلاتك الأكاديمية"), style: const TextStyle(color: Colors.black38, fontSize: 12)),
                const SizedBox(height: 20),
                _buildTextField(_eduInstitutionController, "Education Institution", Icons.school_outlined),
                const SizedBox(height: 15),
                _buildTextField(_eduDegreeController, "Academic Degree", Icons.workspace_premium_outlined),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_eduDurationController, "Duration", Icons.timer_outlined)),
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
                      const Icon(Icons.school, color: Color(0xFF49769F)),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entry.value['institution'] ?? "", style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                            Text("${entry.value['degree']} (${entry.value['duration']})", style: const TextStyle(color: Colors.black54, fontSize: 12)),
                          ],
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20), onPressed: () => setState(() => _educationList.removeAt(entry.key))),
                    ],
                  ),
                )).toList(),
                const SizedBox(height: 30),

                // Skills
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
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade300)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF49769F))),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8, children: _skillsList.map((s) => Chip(label: Text(s, style: const TextStyle(color: Colors.black87, fontSize: 11)), backgroundColor: const Color(0xFF49769F).withOpacity(0.1), onDeleted: () => setState(() => _skillsList.remove(s)), deleteIcon: const Icon(Icons.close, size: 14, color: Colors.black54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))).toList()),
                const SizedBox(height: 30),

                // Social Links
                Text(t.socialMedia, style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_instagramController, "Instagram", Icons.camera_alt_outlined)),
                    const SizedBox(width: 15),
                    Expanded(child: _buildTextField(_facebookController, "Facebook", Icons.facebook_outlined)),
                  ],
                ),
                const SizedBox(height: 40),

                // Save Profile Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveTradesmanProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF49769F),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(t.saveProfile, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadBox(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.cloud_upload_outlined, color: Theme.of(context).colorScheme.primary, size: 30),
              const SizedBox(height: 8),
              Text(text, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38), fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption(String role) {
    bool isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () {
        if (role == "Job Seeker") Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor.withOpacity(0.12), width: 1.5),
          boxShadow: isSelected ? [BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
        ),
        alignment: Alignment.center,
        child: Text(
          role,
          style: TextStyle(
            color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData? icon, {String? hint, String? prefixText, int maxLines = 1, TextInputType keyboardType = TextInputType.text, bool isRequired = false, VoidCallback? onIconTap, IconData? suffixIcon, VoidCallback? onSuffixTap, List<TextInputFormatter>? inputFormatters, String? Function(String?)? validator, bool obscureText = false}) {
    return TextFormField(
      controller: controller, maxLines: maxLines, keyboardType: keyboardType, inputFormatters: inputFormatters, 
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
      obscureText: obscureText,
      validator: isRequired ? (validator ?? (value) => (value == null || value.isEmpty) ? "$label is required" : null) : null,
      decoration: InputDecoration(
        prefixText: prefixText, prefixStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
        labelText: label, labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54), fontSize: 14),
        hintText: hint, hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.26), fontSize: 12),
        prefixIcon: icon != null ? InkWell(onTap: onIconTap, child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20)) : null,
        suffixIcon: suffixIcon != null ? IconButton(icon: Icon(suffixIcon, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54)), onPressed: onSuffixTap) : null,
        filled: true, fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.white, contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.12))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.12))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)),
      ),
    );
  }

  Widget _buildDropdownField({required String label, required IconData icon, required String? value, required List<String> items, required ValueChanged<String?> onChanged, bool isRequired = false}) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)))).toList(),
      onChanged: onChanged,
      dropdownColor: Theme.of(context).cardColor,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      validator: isRequired ? (v) => v == null ? "$label is required" : null : null,
      decoration: InputDecoration(
        labelText: label, labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54), fontSize: 14),
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
        filled: true, fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.12))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.12))),
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
}
