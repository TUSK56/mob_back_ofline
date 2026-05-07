// Post job wizard — step 3: Benefits and Perks
import 'package:flutter/material.dart';
import '../../../../app/router/app_router.dart';
import '../../../../shared/l10n/app_localizations.dart';
import '../../../../shared/models/job.dart';
import '../../../../shared/services/recruitment_sync_service.dart';
import '../../../../shared/state/company_store.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/section_title.dart';

class CompanyPostJobStep3BenefitsScreen extends StatefulWidget {
  const CompanyPostJobStep3BenefitsScreen({super.key});

  @override
  State<CompanyPostJobStep3BenefitsScreen> createState() =>
      _CompanyPostJobStep3BenefitsScreenState();
}

class _CompanyPostJobStep3BenefitsScreenState
    extends State<CompanyPostJobStep3BenefitsScreen> {
  final List<JobBenefit> _benefits = [];
  bool _loading = false;

  bool _initialized = false;
  bool _isEditing = false;
  String? _jobId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        _jobId = args['jobId'];
        _isEditing = _jobId != null;
        
        final benefits = args['benefits'] as List<JobBenefit>?;
        if (benefits != null && benefits.isNotEmpty) {
          _benefits.clear();
          _benefits.addAll(benefits);
        }
      }
      _initialized = true;
    }
  }

  Future<void> _addBenefit() async {
    final t = AppLocalizations.of(context);
    final titleController = TextEditingController();
    final descController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.tr(en: "Add Benefit", ar: "إضافة ميزة")),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: t.tr(en: "Benefit Title", ar: "عنوان الميزة"),
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: InputDecoration(
                hintText: t.tr(en: "Description", ar: "الوصف"),
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                setState(() {
                  _benefits.add(JobBenefit(
                    title: titleController.text.trim(),
                    description: descController.text.trim(),
                  ));
                });
              }
              Navigator.of(ctx).pop();
            },
            child: Text(t.save),
          ),
        ],
      ),
    );
  }

  Future<void> _publish() async {
    setState(() => _loading = true);
    
    final args = ModalRoute.of(context)?.settings.arguments;
    final data = args is Map<String, dynamic> ? args : const <String, dynamic>{};
    
    final title = (data['title'] as String?)?.trim() ?? 'Untitled Job';
    final employmentType = (data['employmentType'] as String?)?.trim() ?? 'Full-Time';
    final salaryRange = (data['salaryRange'] as String?)?.trim() ?? 'Competitive';
    final step1Description = (data['description'] as String?) ?? '';
    final descriptionPoints = (data['descriptionPoints'] as List<String>?) ?? [];
    final classification = (data['classification'] as String?) ?? 'General';
    final department = (data['department'] as String?) ?? '';
    final positions = (data['positions'] as int?) ?? 1;
    final responsibilities = (data['responsibilities'] as List<String>?) ?? [];
    final niceToHaves = (data['niceToHaves'] as List<String>?) ?? [];
    final qualifications = (data['qualifications'] as List<String>?) ?? [];
    final deadline = data['deadline'] as DateTime?;

    final fullDescription = [
      if (step1Description.isNotEmpty) step1Description,
      ...descriptionPoints
    ].join('\n');

    final companyLocations = CompanyStore.instance.locations;
    final location = companyLocations.isNotEmpty ? companyLocations.first : 'Remote';

    try {
      if (_isEditing && _jobId != null) {
        await RecruitmentSyncService.instance.updateJob(
          jobId: _jobId!,
          title: title,
          location: location,
          salaryRange: salaryRange,
          description: fullDescription,
          responsibilities: responsibilities,
          qualifications: qualifications,
          niceToHaves: niceToHaves,
          benefits: _benefits.map((b) => b.description.isEmpty ? b.title : "${b.title}:::${b.description}").toList(),
          classification: classification,
          companyName: CompanyStore.instance.companyName,
          type: employmentType,
          tags: [classification, department].where((s) => s.isNotEmpty).toList(),
          requiredCount: positions,
          deadline: deadline,
        );
      } else {
        await RecruitmentSyncService.instance.postJob(
          title: title,
          location: location,
          salaryRange: salaryRange,
          description: fullDescription,
          responsibilities: responsibilities,
          qualifications: qualifications,
          niceToHaves: niceToHaves,
          benefits: _benefits.map((b) => b.description.isEmpty ? b.title : "${b.title}:::${b.description}").toList(),
          classification: classification,
          companyName: CompanyStore.instance.companyName,
          type: employmentType,
          tags: [classification, department].where((s) => s.isNotEmpty).toList(),
          requiredCount: positions,
          deadline: deadline,
        );
      }

      if (!mounted) return;
      setState(() => _loading = false);
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.companyDashboard, (r) => false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post job: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return AppScaffold(
      title: _isEditing ? t.editJob : t.postJob,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 10),
          SectionTitle(t.step3Label),
          const SizedBox(height: 8),
          Text(
            t.tr(en: "This job comes with many perks and benefits.", ar: "هذه الوظيفة تأتي مع العديد من المزايا والفوائد"),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.4,
            ),
            itemCount: _benefits.length + 1,
            itemBuilder: (context, index) {
              if (index < _benefits.length) {
                final b = _benefits[index];
                return _BenefitCard(
                  benefit: b,
                  onDelete: () => setState(() => _benefits.removeAt(index)),
                );
              } else {
                return _AddBenefitCard(onTap: _addBenefit);
              }
            },
          ),
          const SizedBox(height: 48),
          AppButton(label: t.save, loading: _loading, onPressed: _publish),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _BenefitCard extends StatelessWidget {
  final JobBenefit benefit;
  final VoidCallback onDelete;
  const _BenefitCard({required this.benefit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  benefit.title,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              InkWell(
                onTap: onDelete,
                child: Icon(Icons.close, size: 16, color: Theme.of(context).colorScheme.error.withOpacity(0.5)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              benefit.description,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                fontSize: 12,
                height: 1.4,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddBenefitCard extends StatelessWidget {
  final VoidCallback onTap;
  const _AddBenefitCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            style: BorderStyle.solid,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Theme.of(context).colorScheme.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              t.tr(en: "Add Benefit", ar: "إضافة ميزة"),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
