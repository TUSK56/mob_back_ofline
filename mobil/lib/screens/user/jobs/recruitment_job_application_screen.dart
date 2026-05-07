import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import '../../../shared/services/recruitment_sync_service.dart';
import '../../../shared/state/recruitment_sync_store.dart';
import '../../../shared/widgets/app_button.dart';

class RecruitmentJobApplicationScreen extends StatefulWidget {
  const RecruitmentJobApplicationScreen({super.key, required this.job});

  final RecruitmentJob job;

  @override
  State<RecruitmentJobApplicationScreen> createState() =>
      _RecruitmentJobApplicationScreenState();
}

class _RecruitmentJobApplicationScreenState
    extends State<RecruitmentJobApplicationScreen> {
  final _portfolio = TextEditingController();
  final _cover = TextEditingController();
  final _linkedIn = TextEditingController();
  bool _loading = false;
  String? _selectedCVName;

  @override
  void dispose() {
    _portfolio.dispose();
    _cover.dispose();
    _linkedIn.dispose();
    super.dispose();
  }

  Future<void> _pickCV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    
    if (result != null) {
      setState(() {
        _selectedCVName = result.files.single.name;
      });
    }
  }

  Future<void> _submit(bool isAr) async {
    if (_cover.text.trim().isEmpty || _selectedCVName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isAr ? 'يرجى رفع السيرة الذاتية وكتابة خطاب التغطية.' : 'Please upload your CV and write a Cover Letter.')),
      );
      return;
    }
    
    setState(() => _loading = true);
    try {
      await RecruitmentSyncService.instance.applyToJob(
        jobId: widget.job.id,
        userName: RecruitmentSyncStore.instance.currentUserName,
      );
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isAr ? 'تم تقديم الطلب بنجاح.' : 'Application submitted successfully.')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isAr ? 'حدث خطأ أثناء تقديم الطلب.' : 'Error submitting application.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          isAr ? 'التقديم للوظيفة' : 'Apply to Job',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.job.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 6),
                // تم إخفاء اسم الشركة بناءً على طلبك السابق في صفحات أخرى إذا كنت ترغب في ذلك، 
                // هنا ما زال يظهر لضمان معرفة المستخدم لمن يرسل الطلب.
                Text(
                  widget.job.companyName,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          _buildInputField(isAr ? 'رابط معرض الأعمال (Portfolio)' : 'Portfolio URL', _portfolio),
          _buildInputField(isAr ? 'رابط LinkedIn' : 'LinkedIn URL', _linkedIn),
          
          const SizedBox(height: 8),
          Text(isAr ? 'السيرة الذاتية (CV) *' : 'Curriculum Vitae (CV) *', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickCV,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.description_outlined, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedCVName ?? (isAr ? 'ارفع سيرتك الذاتية (PDF, DOC)' : 'Upload your CV (PDF, DOC)'),
                      style: TextStyle(color: _selectedCVName == null ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5) : Theme.of(context).colorScheme.onSurface),
                    ),
                  ),
                  Icon(Icons.cloud_upload_outlined, color: Theme.of(context).colorScheme.primary),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          _buildInputField(isAr ? 'خطاب التغطية *' : 'Cover letter *', _cover, maxLines: 5),
          
          const SizedBox(height: 24),
          AppButton(
            label: isAr ? 'تقديم الطلب' : 'Submit Application',
            loading: _loading,
            onPressed: _loading ? null : () => _submit(isAr),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, 
      {TextInputType? keyboardType, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.2)),
          ),
        ),
      ),
    );
  }
}
