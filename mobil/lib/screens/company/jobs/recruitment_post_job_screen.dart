import 'package:flutter/material.dart';

import '../../../shared/services/recruitment_sync_service.dart';
import '../../../shared/state/company_store.dart';

class RecruitmentPostJobScreen extends StatefulWidget {
  const RecruitmentPostJobScreen({super.key});

  @override
  State<RecruitmentPostJobScreen> createState() => _RecruitmentPostJobScreenState();
}

class _RecruitmentPostJobScreenState extends State<RecruitmentPostJobScreen> {
  final _titleController = TextEditingController();
  final _departmentController = TextEditingController(text: 'Engineering');
  final _locationController = TextEditingController(text: 'Remote');
  final _typeController = TextEditingController(text: 'Full-time');
  final _salaryController = TextEditingController(text: 'Negotiable');
  final _descriptionController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _benefitsController = TextEditingController();
  final _screeningController = TextEditingController();
  final _niceToHave = TextEditingController();
  final _skillsController = TextEditingController();
  int _step = 0;
  bool _loading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _departmentController.dispose();
    _locationController.dispose();
    _typeController.dispose();
    _salaryController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    _benefitsController.dispose();
    _screeningController.dispose();
    _niceToHave.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  bool _validateStep0() {
    return _titleController.text.trim().isNotEmpty &&
        _departmentController.text.trim().isNotEmpty &&
        _locationController.text.trim().isNotEmpty &&
        _typeController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post New Job')),
      body: Stepper(
        currentStep: _step,
        onStepContinue: () async {
          if (_step == 0 && !_validateStep0()) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please complete required basics.')),
            );
            return;
          }
          if (_step < 1) {
            setState(() => _step += 1);
            return;
          }
          setState(() => _loading = true);
          await RecruitmentSyncService.instance.postJob(
            title: _titleController.text.trim().isEmpty
                ? 'Untitled Role'
                : _titleController.text.trim(),
            location: _locationController.text.trim().isEmpty
                ? 'Remote'
                : _locationController.text.trim(),
            salaryRange: _salaryController.text.trim().isEmpty
                ? 'Negotiable'
                : _salaryController.text.trim(),
            description: _descriptionController.text.trim(),
            responsibilities: _requirementsController.text
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList(),
            qualifications: const [],
            benefits: _benefitsController.text
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList(),
            classification: _departmentController.text.trim().isEmpty 
                ? 'Engineering' 
                : _departmentController.text.trim(),
            companyName: CompanyStore.instance.companyName.isEmpty 
                ? 'Jobito Recruiter' 
                : CompanyStore.instance.companyName,
            type: _typeController.text.trim().isEmpty
                ? 'Full-time'
                : _typeController.text.trim(),
            tags: _skillsController.text
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList(),
            niceToHaves: _niceToHave.text
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList(),
          );
          if (!context.mounted) return;
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Job posted')),
          );
          Navigator.of(context).pop();
        },
        onStepCancel: () {
          if (_step == 0) {
            Navigator.of(context).pop();
            return;
          }
          setState(() => _step -= 1);
        },
        steps: [
          Step(
            title: const Text('Job Information'),
            isActive: _step == 0,
            content: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Job title *'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _departmentController,
                  decoration: const InputDecoration(labelText: 'Department *'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'Location *'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _typeController,
                  decoration: const InputDecoration(
                    labelText: 'Employment type (Full-time / Part-time) *',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Job description',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Requirements & Compensation'),
            isActive: _step == 1,
            content: Column(
              children: [
                TextField(
                  controller: _requirementsController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Requirements',
                    alignLabelWithHint: true,
                  ),
                ),
                TextField(
                  controller: _niceToHave,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Nice-to-haves (optional)',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _salaryController,
                  decoration: const InputDecoration(labelText: 'Salary range'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _skillsController,
                  decoration: const InputDecoration(
                    labelText: 'Required Skills (comma separated)',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _screeningController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Screening question',
                    alignLabelWithHint: true,
                  ),
                ),
                if (_loading) ...[
                  const SizedBox(height: 20),
                  const LinearProgressIndicator(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
