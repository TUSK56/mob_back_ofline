import 'package:flutter/material.dart';
import 'package:graduationproject/shared/l10n/app_localizations.dart';
import 'package:graduationproject/shared/state/recruitment_sync_store.dart';
import 'package:graduationproject/shared/widgets/app_button.dart';
import 'package:graduationproject/shared/services/recruitment_sync_service.dart';

class TradesmanApplyJobScreen extends StatefulWidget {
  const TradesmanApplyJobScreen({super.key, required this.job});

  final RecruitmentJob job;

  @override
  State<TradesmanApplyJobScreen> createState() => _TradesmanApplyJobScreenState();
}

class _TradesmanApplyJobScreenState extends State<TradesmanApplyJobScreen> {
  final _coverLetterController = TextEditingController();
  final _priceController = TextEditingController();
  final _timeController = TextEditingController();

  @override
  void dispose() {
    _coverLetterController.dispose();
    _priceController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final store = RecruitmentSyncStore.instance;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Image.asset(
          'assets/company/logo/logo.png',
          height: 150,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Job Header Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.job.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          
          _buildTextField(
            t.tr(en: 'Cover Letter', ar: 'خطاب التقديم'), 
            _coverLetterController, 
            Icons.description_outlined, 
            maxLines: 5,
            hint: t.tr(en: 'Explain why you are the best fit...', ar: 'اشرح لماذا أنت الأنسب لهذه الوظيفة...')
          ),
          _buildTextField(
            t.tr(en: 'Price for this job', ar: 'السعر لهذه الوظيفة'), 
            _priceController, 
            Icons.payments_outlined,
            keyboardType: TextInputType.number,
            hint: 'Example: 500 EGP'
          ),
          _buildTextField(
            t.tr(en: 'Time to Complete', ar: 'الوقت المتوقع للإنجاز'), 
            _timeController, 
            Icons.timer_outlined,
            hint: 'Example: 2 days'
          ),
          
          const SizedBox(height: 24),
          AppButton(
            label: t.tr(en: 'Submit Application', ar: 'إرسال الطلب'),
            loading: _loading,
            onPressed: () async {
              if (_coverLetterController.text.isEmpty || _priceController.text.isEmpty || _timeController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t.tr(en: 'Please fill all fields', ar: 'يرجى ملء جميع الحقول'))),
                );
                return;
              }

              setState(() => _loading = true);
              try {
                // Real API Call
                await RecruitmentSyncService.instance.applyToJob(
                  jobId: widget.job.id,
                  userName: store.currentUserName,
                );

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t.tr(en: 'Application Sent!', ar: 'تم إرسال الطلب بنجاح!'))),
                );
                Navigator.pop(context);
              } catch (e) {
                if (!mounted) return;
                setState(() => _loading = false);
                
                String errorMsg = e.toString().contains('already applied') 
                    ? t.tr(en: 'You have already applied for this job', ar: 'لقد قمت بالتقديم لهذه الوظيفة بالفعل')
                    : t.tr(en: 'Failed to send application', ar: 'فشل إرسال الطلب');

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(errorMsg)),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, 
      {TextInputType? keyboardType, int maxLines = 1, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.black87, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black26, fontSize: 13),
          prefixIcon: Icon(icon, color: const Color(0xFF49769F), size: 20),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF49769F)),
          ),
        ),
      ),
    );
  }
}
