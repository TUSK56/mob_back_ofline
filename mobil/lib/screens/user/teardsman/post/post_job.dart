import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:graduationproject/shared/l10n/app_localizations.dart';
import 'package:graduationproject/shared/state/recruitment_sync_store.dart';
import '../../../../shared/services/recruitment_sync_service.dart';
import 'job_applicants_screen.dart';

class PostJob extends StatefulWidget {
  const PostJob({super.key});

  @override
  State<PostJob> createState() => _PostJobState();
}

class _PostJobState extends State<PostJob> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<String> _days = ["Saturday", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday"];
  final Set<String> _selectedDays = {};

  bool _isWorkTimeExpanded = false;

  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images.map((image) => File(image.path)));
      });
    }
  }

  Future<void> _validateAndPost(AppLocalizations t) async {
    if (_formKey.currentState!.validate()) {
      final store = RecruitmentSyncStore.instance;
      
      try {
        final String jobId = await RecruitmentSyncService.instance.postJob(
          title: _titleController.text,
          companyName: store.currentUserName, 
          location: store.currentUserLocation,
          salaryRange: _priceController.text,
          type: 'one-time',
          classification: 'Service',
          tags: _selectedDays.toList(),
          description: _descriptionController.text,
          responsibilities: [],
          qualifications: [],
          niceToHaves: [],
          benefits: [],
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.tr(en: "Job posted successfully!", ar: "تم نشر الوظيفة بنجاح!")),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to applicants screen with the real ID
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobApplicantsScreen(
              jobId: jobId,
              jobTitle: _titleController.text,
              initialDesc: _descriptionController.text,
              initialBudget: _priceController.text,
              initialDays: _selectedDays.toList(),
            ),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.isAr ? 'فشل نشر الوظيفة' : 'Failed to post job'),
            backgroundColor: Colors.redAccent,
          ),
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
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF011931)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          t.tr(en: "Post job", ar: "نشر وظيفة"),
          style: const TextStyle(
            color: Color(0xFF011931),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JobApplicantsScreen(
                      jobId: "", // Generic view
                      jobTitle: _titleController.text.isEmpty ? (t.isAr ? "بدون عنوان" : "Untitled") : _titleController.text,
                    ),
                  ),
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF49769F).withOpacity(0.1),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                t.tr(en: "Applicants", ar: "المتقدمين"),
                style: const TextStyle(
                  color: Color(0xFF49769F),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // Basic Information Header
              _buildSectionHeader(
                  t.tr(en: "Basic Information", ar: "معلومات أساسية"),
                  t.tr(en: "This information will be displayed publicly", ar: "سيتم عرض هذه المعلومات بشكل علني")
              ),
              const Divider(color: Colors.black12, height: 40),

              // Service Title (Job Title)
              _buildSideTitleSection(
                isVertical: true,
                title: "${t.tr(en: "Service Title", ar: "عنوان الخدمة")} *",
                subtitle: t.tr(en: "Describe your profession", ar: "صف مهنتك"),
                child: _buildTextField(
                  controller: _titleController,
                  hint: "example Professional Plumber",
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return t.tr(en: "Service title is required", ar: "عنوان الخدمة مطلوب");
                    }
                    return null;
                  },
                ),
              ),
              const Divider(color: Colors.black12, height: 40),

              // Description
              _buildSideTitleSection(
                isVertical: true,
                title: "${t.tr(en: "Description", ar: "الوصف")} *",
                subtitle: t.tr(en: "Detail your services", ar: "فصل خدماتك"),
                child: _buildTextField(
                  controller: _descriptionController,
                  hint: "Enter detailed description",
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return t.tr(en: "Description is required", ar: "الوصف مطلوب");
                    }
                    return null;
                  },
                ),
              ),
              const Divider(color: Colors.black12, height: 40),

              // Starting Price
              _buildSideTitleSection(
                isVertical: true,
                title: t.tr(en: "Starting Price", ar: "السعر المبدئي"),
                subtitle: t.tr(en: "Price starts from...", ar: "يبدأ السعر من..."),
                child: _buildTextField(
                  controller: _priceController,
                  hint: "example 150 EGP",
                  keyboardType: TextInputType.number,
                ),
              ),
              const Divider(color: Colors.black12, height: 40),

              // Work Time
              _buildSideTitleSection(
                title: t.tr(en: "Work time", ar: "وقت العمل"),
                subtitle: t.tr(en: "Available days", ar: "الأيام المتاحة"),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _isWorkTimeExpanded = !_isWorkTimeExpanded),
                      child: _buildSmallDropdown(_selectedDays.isEmpty
                          ? t.tr(en: "Select", ar: "اختر")
                          : (_selectedDays.length == 7 ? t.tr(en: "All days", ar: "كل الأيام") : "${_selectedDays.length} ${t.tr(en: "Days", ar: "أيام")}")),
                    ),
                    if (_isWorkTimeExpanded) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.withOpacity(0.2)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            _buildDayItem(t.tr(en: "All Days", ar: "كل الأيام"), isSpecial: true),
                            const Divider(color: Colors.black12, height: 1),
                            ..._days.map((day) => _buildDayItem(day)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Divider(color: Colors.black12, height: 40),

              // Images
              _buildSideTitleSection(
                title: t.tr(en: "Work Images", ar: "صور العمل"),
                subtitle: t.tr(en: "Showcase your work", ar: "اعرض عملك"),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: _pickImages,
                      child: Container(
                        width: double.infinity,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF49769F).withOpacity(0.3), width: 1.5),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.cloud_upload_outlined, color: Color(0xFF49769F), size: 30),
                            const SizedBox(height: 8),
                            Text(
                              t.tr(en: "Upload work images", ar: "ارفع صور لعملك"),
                              style: const TextStyle(color: Color(0xFF49769F), fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_selectedImages.isNotEmpty) ...[
                      const SizedBox(height: 15),
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(image: FileImage(_selectedImages[index]), fit: BoxFit.cover),
                                  ),
                                ),
                                Positioned(
                                  top: 2,
                                  right: 12,
                                  child: GestureDetector(
                                    onTap: () => setState(() => _selectedImages.removeAt(index)),
                                    child: Container(
                                      decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                                      child: const Icon(Icons.close, color: Colors.white, size: 16),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Bottom Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _validateAndPost(t),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF49769F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 2,
                  ),
                  child: Text(
                      t.tr(en: "Post job", ar: "نشر وظيفة"),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: Colors.black38, fontSize: 12)),
      ],
    );
  }

  Widget _buildSideTitleSection({required String title, required String subtitle, required Widget child, bool isVertical = false}) {
    if (isVertical) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.bold)),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.black38, fontSize: 11)),
          ],
          const SizedBox(height: 12),
          child,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.bold)),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.black38, fontSize: 11)),
              ],
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 5,
          child: child,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.black87, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black26, fontSize: 13),
        contentPadding: const EdgeInsets.all(12),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFF49769F), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildSmallDropdown(String hint) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(hint, style: const TextStyle(color: Colors.black54, fontSize: 12), overflow: TextOverflow.ellipsis)),
          Icon(
            _isWorkTimeExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: Colors.black38,
            size: 16
          ),
        ],
      ),
    );
  }

  Widget _buildDayItem(String day, {bool isSpecial = false}) {
    bool isSelected = isSpecial
        ? _selectedDays.length == 7
        : _selectedDays.contains(day);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSpecial) {
            if (_selectedDays.length == 7) {
              _selectedDays.clear();
            } else {
              _selectedDays.addAll(_days);
            }
          } else {
            if (isSelected) {
              _selectedDays.remove(day);
            } else {
              _selectedDays.add(day);
            }
          }
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF49769F).withOpacity(0.1) : Colors.transparent,
          border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.05))),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
              color: isSelected ? const Color(0xFF49769F) : Colors.black26,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              day,
              style: TextStyle(
                color: isSelected ? Colors.black87 : Colors.black54,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
