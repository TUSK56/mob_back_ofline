import 'package:flutter/material.dart';

import '../../../shared/state/recruitment_sync_store.dart';
import '../../../shared/widgets/app_button.dart';

class RecruitmentCompanyProfileScreen extends StatefulWidget {
  const RecruitmentCompanyProfileScreen({super.key});

  @override
  State<RecruitmentCompanyProfileScreen> createState() =>
      _RecruitmentCompanyProfileScreenState();
}

class _RecruitmentCompanyProfileScreenState
    extends State<RecruitmentCompanyProfileScreen> {
  final _nameController = TextEditingController(text: 'Jobito Labs');
  final _aboutController = TextEditingController(
    text:
        'We build modern hiring products connecting great companies with top candidates.',
  );

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = RecruitmentSyncStore.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Company Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Company name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _aboutController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'About company'),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'Save',
              onPressed: () {
                store.companySendMessage(
                  'Company profile updated by ${_nameController.text.trim()}.',
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Company profile saved')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
