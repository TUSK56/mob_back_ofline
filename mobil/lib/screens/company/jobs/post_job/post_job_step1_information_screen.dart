// Post job wizard — step 1: core job fields.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/router/app_router.dart';
import '../../../../shared/l10n/app_localizations.dart';
import '../../../../shared/models/job.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/section_title.dart';

class CompanyPostJobStep1InformationScreen extends StatefulWidget {
  const CompanyPostJobStep1InformationScreen({super.key});

  @override
  State<CompanyPostJobStep1InformationScreen> createState() =>
      _CompanyPostJobStep1InformationScreenState();
}

class _CompanyPostJobStep1InformationScreenState
    extends State<CompanyPostJobStep1InformationScreen> {
  final _jobTitle = TextEditingController();
  final _jobDescription = TextEditingController();
  final _salaryController = TextEditingController();
  final _positions = TextEditingController();
  final _department = TextEditingController();
  DateTime? _deadline = DateTime.now().add(const Duration(days: 30));
  String _classification = 'Technical'; // Technical, Non-Technical, Service
  final Set<String> _types = {'Full-Time'};
  final List<String> _skills = [];
  bool _loading = false;
  String? _titleError;
  String? _positionsError;

  bool _initialized = false;
  Job? _editingJob;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Job) {
        _editingJob = args;
        _jobTitle.text = args.title;
        _jobDescription.text = args.description;
        _positions.text = args.requiredCount.toString();
        _department.text = args.department;
        _classification = args.classification;
        
        _types.clear();
        _types.add(args.employmentType);

        // Simple salary parsing to keep value on edit
        final salary = args.salaryRange;
        final digitsOnly = salary.replaceAll(RegExp(r'[^\d]'), '');
        if (digitsOnly.isNotEmpty) {
          _salaryController.text = digitsOnly.replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
        } else {
          _salaryController.text = salary == 'Competitive' ? '' : salary;
        }
        
        _positions.text = args.requiredCount.toString();
        _types.clear();
        _types.addAll(args.employmentType.split(' • '));
        _skills.clear();
        // Since we don't have separate skills list in model, we use responsibilities or qualifications
        // For now, let's keep it as is or leave empty.
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _jobTitle.dispose();
    _jobDescription.dispose();
    _salaryController.dispose();
    _positions.dispose();
    _department.dispose();
    super.dispose();
  }

  bool _validate() {
    final t = AppLocalizations.of(context);
    setState(() {
      _titleError = _jobTitle.text.trim().length >= 3 ? null : t.at3Chars;
      
      final posText = _positions.text.trim();
      final posInt = int.tryParse(posText);
      if (posText.isEmpty || posInt == null || posInt < 1) {
        _positionsError = t.isAr ? 'يرجى إدخال رقم صحيح وموجب' : 'Please enter a valid positive number';
      } else {
        _positionsError = null;
      }
    });
    return _titleError == null && _positionsError == null;
  }

  Future<void> _next() async {
    if (!_validate()) return;
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).pushNamed(
      AppRoutes.companyPostJobStep2,
      arguments: {
        'jobId': _editingJob?.id,
        'title': _jobTitle.text.trim(),
        'employmentType': _types.join(' • '),
        'salaryRange': _salaryController.text.trim().isEmpty ? 'Competitive' : _salaryController.text.trim(),
        'description': _jobDescription.text.trim(),
        'positions': int.tryParse(_positions.text) ?? 1,
        'classification': _classification,
        'department': _department.text.trim(),
        'skills': _skills,
        'deadline': _deadline,
        // Pass existing lists if editing
        'responsibilities': _editingJob?.responsibilities,
        'qualifications': _editingJob?.qualifications,
        'niceToHaves': _editingJob?.niceToHaves,
        'benefits': _editingJob?.benefits,
      },
    );
  }

  Future<void> _addSkill() async {
    final t = AppLocalizations.of(context);
    final controller = TextEditingController();
    final newSkill = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.tr(en: 'Add Skill', ar: 'إضافة مهارة')),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: t.tr(en: 'Enter skill', ar: 'أدخل المهارة'),
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (val) => Navigator.of(ctx).pop(val),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: Text(t.save),
          ),
        ],
      ),
    );
    if (newSkill != null && newSkill.trim().isNotEmpty) {
      setState(() => _skills.add(newSkill.trim()));
    }
  }

  Future<void> _selectDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }

  void _toggle(String type) {
    setState(() {
      if (_types.contains(type)) {
        _types.remove(type);
      } else {
        _types.add(type);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return AppScaffold(
      title: _editingJob != null ? t.editJob : t.postJob,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 10),
          SectionTitle(t.step1Label),
          const SizedBox(height: 16),
          AppTextField(
            label: t.jobTitle,
            controller: _jobTitle,
            hint: t.jobTitleHint,
            validatorText: _titleError,
          ),
          const SizedBox(height: 24),
          AppTextField(
            label: t.jobDescriptions,
            controller: _jobDescription,
            hint: t.addDescription,
            maxLines: 5,
          ),
          const Divider(height: 48),
          Text(
            t.typeOfEmployment,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _TypeChip(
                label: 'Full-Time',
                selected: _types.contains('Full-Time'),
                onTap: () => _toggle('Full-Time'),
              ),
              _TypeChip(
                label: 'Remote',
                selected: _types.contains('Remote'),
                onTap: () => _toggle('Remote'),
              ),
              _TypeChip(
                label: 'Part-Time',
                selected: _types.contains('Part-Time'),
                onTap: () => _toggle('Part-Time'),
              ),
              _TypeChip(
                label: 'Internship',
                selected: _types.contains('Internship'),
                onTap: () => _toggle('Internship'),
              ),
              _TypeChip(
                label: 'One Time',
                selected: _types.contains('One Time'),
                onTap: () => _toggle('One Time'),
              ),
              _TypeChip(
                label: 'Freelance',
                selected: _types.contains('Freelance'),
                onTap: () => _toggle('Freelance'),
              ),
            ],
          ),
          const Divider(height: 48),
          AppTextField(
            label: t.salary,
            controller: _salaryController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _CommaTextInputFormatter(),
            ],
            hint: t.tr(en: "e.g. 5000", ar: "مثال: 5000"),
          ),
          const Divider(height: 48),
          Text(
            t.requiredSkills,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ..._skills.map(
                (s) => InputChip(
                  label: Text(s),
                  onDeleted: () => setState(() => _skills.remove(s)),
                ),
              ),
              ActionChip(
                label: Text(t.tr(en: '+ Add', ar: '+ إضافة'), style: const TextStyle(fontSize: 12)),
                onPressed: _addSkill,
                visualDensity: VisualDensity.compact,
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                side: BorderSide.none,
              ),
            ],
          ),
          const Divider(height: 48),

          // Number of Positions
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.tr(en: "Positions", ar: "العدد المطلوب"),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, fontSize: 15),
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: '',
                controller: _positions,
                hint: t.tr(en: "e.g. 1", ar: "حدد عدد المقاعد المتاحة لهذا المنصب"),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validatorText: _positionsError,
              ),
            ],
          ),
          const Divider(height: 48),

          // Classification
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.tr(en: "Classification", ar: "التصنيف"),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, fontSize: 15),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildRadioChip(t.tr(en: "Technical", ar: "تقني"), "Technical"),
                    const SizedBox(width: 8),
                    _buildRadioChip(t.tr(en: "Non-Technical", ar: "غير تقني"), "Non-Technical"),
                    const SizedBox(width: 8),
                    _buildRadioChip(t.tr(en: "Service", ar: "خدمات"), "Service"),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 48),

          // Department
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.tr(en: "Job Department", ar: "القسم الوظيفي"),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, fontSize: 15),
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: '',
                controller: _department,
                hint: t.tr(en: "e.g. Engineering, Marketing...", ar: "اكتب فئة الوظيفة المناسبة... مثال: هندسة، تسويق"),
              ),
            ],
          ),
          const Divider(height: 48),

          // Deadline
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.tr(en: "Deadline", ar: "تاريخ انتهاء التقديم"),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, fontSize: 15),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _selectDeadline,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _deadline == null 
                          ? (t.isAr ? 'متى سيغلق باب التقديم؟' : 'When will it close?')
                          : "${_deadline!.month.toString().padLeft(2, '0')}/${_deadline!.day.toString().padLeft(2, '0')}/${_deadline!.year}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Icon(Icons.calendar_month_outlined, size: 20, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 48),
          
          AppButton(label: t.nextStep, loading: _loading, onPressed: _next),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildRadioChip(String label, String value) {
    final selected = _classification == value;
    final color = selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.1);
    return InkWell(
      onTap: () => setState(() => _classification = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: selected ? 0.3 : 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
                fontSize: 12,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = selected
        ? cs.primary
        : cs.onSurface.withOpacity(0.12);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: selected ? 0.3 : 0.5)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : cs.onSurface,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _CommaTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    
    // Only allow digits for formatting
    final newText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (newText.isEmpty) return newValue.copyWith(text: '');

    // Format with commas
    final formatted = newText.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
