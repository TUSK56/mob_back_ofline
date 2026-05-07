import 'package:flutter/material.dart';

import '../../../shared/services/recruitment_sync_service.dart';
import '../../../shared/state/recruitment_sync_store.dart';
import '../../../shared/widgets/app_button.dart';

class RecruitmentCandidateDetailsScreen extends StatelessWidget {
  const RecruitmentCandidateDetailsScreen({super.key, required this.application});

  final RecruitmentApplication application;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Candidate Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              application.userName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text('Applied for: ${application.jobTitle}'),
            Text('Current: ${application.status}'),
            const SizedBox(height: 16),
            const Text(
              'Candidate Summary',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Strong mobile background with clean architecture and production delivery experience.',
            ),
            const SizedBox(height: 20),
            AppButton(
              label: 'Move To Final Review',
              onPressed: () => RecruitmentSyncService.instance.updateStatus(
                applicationId: application.id,
                status: 'Final Review',
              ),
            ),
            const SizedBox(height: 10),
            AppButton(
              label: 'Hire Candidate',
              variant: AppButtonVariant.secondary,
              onPressed: () => RecruitmentSyncService.instance.updateStatus(
                applicationId: application.id,
                status: 'Hired',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
