// Post job wizard — step 2: Detailed sections (Responsibilities, Qualifications, etc.)
import 'package:flutter/material.dart';
import '../../../../app/router/app_router.dart';
import '../../../../shared/l10n/app_localizations.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/section_title.dart';

class CompanyPostJobStep2DescriptionScreen extends StatefulWidget {
  const CompanyPostJobStep2DescriptionScreen({super.key});

  @override
  State<CompanyPostJobStep2DescriptionScreen> createState() =>
      _CompanyPostJobStep2DescriptionScreenState();
}

class _CompanyPostJobStep2DescriptionScreenState
    extends State<CompanyPostJobStep2DescriptionScreen> {
  final List<TextEditingController> _descriptionPoints = [TextEditingController()];
  final List<TextEditingController> _responsibilities = [TextEditingController()];
  final List<TextEditingController> _qualifications = [TextEditingController()];
  final List<TextEditingController> _niceToHaves = [TextEditingController()];
  
  bool _loading = false;

  bool _initialized = false;
  bool _isEditing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        _isEditing = args['jobId'] != null;
        
        final resp = args['responsibilities'] as List<String>?;
        if (resp != null && resp.isNotEmpty) {
          _responsibilities.clear();
          for (var r in resp) {
            _responsibilities.add(TextEditingController(text: r));
          }
        }
        
        final qual = args['qualifications'] as List<String>?;
        if (qual != null && qual.isNotEmpty) {
          _qualifications.clear();
          for (var q in qual) {
            _qualifications.add(TextEditingController(text: q));
          }
        }
        
        final nice = args['niceToHaves'] as List<String>?;
        if (nice != null && nice.isNotEmpty) {
          _niceToHaves.clear();
          for (var n in nice) {
            _niceToHaves.add(TextEditingController(text: n));
          }
        }

        final descPoints = args['descriptionPoints'] as List<String>?;
        if (descPoints != null && descPoints.isNotEmpty) {
          _descriptionPoints.clear();
          for (var p in descPoints) {
            _descriptionPoints.add(TextEditingController(text: p));
          }
        }
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    for (var c in _descriptionPoints) {
      c.dispose();
    }
    for (var c in _responsibilities) {
      c.dispose();
    }
    for (var c in _qualifications) {
      c.dispose();
    }
    for (var c in _niceToHaves) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _next() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    setState(() => _loading = false);

    final args = ModalRoute.of(context)?.settings.arguments;
    final data = args is Map<String, dynamic> ? args : const <String, dynamic>{};
    
    Navigator.of(context).pushNamed(
      AppRoutes.companyPostJobStep3,
      arguments: {
        ...data,
        'responsibilities': _responsibilities.map((e) => e.text.trim()).where((e) => e.isNotEmpty).toList(),
        'niceToHaves': _niceToHaves.map((e) => e.text.trim()).where((e) => e.isNotEmpty).toList(),
        'qualifications': _qualifications.map((e) => e.text.trim()).where((e) => e.isNotEmpty).toList(),
        'descriptionPoints': _descriptionPoints.map((e) => e.text.trim()).where((e) => e.isNotEmpty).toList(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return AppScaffold(
      title: _isEditing ? t.editJob : t.postJob,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionTitle(t.step2Label),
          const SizedBox(height: 12),
          
          _buildDynamicSection(
            title: t.tr(en: "Responsibilities", ar: "المسؤوليات"),
            subtitle: t.tr(en: "Define core duties.", ar: "حدد المسؤوليات الأساسية لهذا المنصب"),
            hint: t.tr(en: "e.g. Community participation...", ar: "...مثال: المشاركة المجتمعية لضمان"),
            points: _responsibilities,
          ),

          const Divider(height: 48),

          _buildDynamicSection(
            title: t.tr(en: "Required Qualifications", ar: "المؤهلات المطلوبة"),
            subtitle: t.tr(en: "Add qualifications you prefer.", ar: "أضف المؤهلات التي تفضلها في المرشحين"),
            hint: t.tr(en: "e.g. You are a growth marketer...", ar: "...مثال: أنت مسوق نمو وتعرف كيف"),
            points: _qualifications,
          ),

          const Divider(height: 48),

          _buildDynamicSection(
            title: t.tr(en: "Nice-To-Haves", ar: "مزايا إضافية (Nice-To-Haves)"),
            subtitle: t.tr(en: "Encourage diverse applicants.", ar: "شجع مجموعة متنوعة من المرشحين على التقديم"),
            hint: t.tr(en: "e.g. English fluency...", ar: "...مثال: طلاقة في اللغة الإنجليزية، إدارة المشاريع"),
            points: _niceToHaves,
          ),

          const Divider(height: 64),
          AppButton(label: t.nextStep, loading: _loading, onPressed: _next),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDynamicSection({
    required String title,
    required String subtitle,
    required String hint,
    required List<TextEditingController> points,
  }) {
    final t = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        const SizedBox(height: 16),
        ...points.asMap().entries.map((entry) {
          int idx = entry.key;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                ),
              ),
              child: TextField(
                controller: points[idx],
                decoration: InputDecoration(
                  hintText: subtitle,
                  hintStyle: const TextStyle(fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          );
        }),
        const SizedBox(height: 4),
        InkWell(
          onTap: () => setState(() => points.add(TextEditingController())),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, size: 18, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  t.tr(en: "Add another point", ar: "إضافة نقطة أخرى"),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
