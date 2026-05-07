import 'package:flutter/material.dart';

import '../../../app/router/app_router.dart';
import '../../../shared/utils/image_helper.dart';
import '../../../shared/state/recruitment_sync_store.dart';
import '../../../shared/widgets/app_button.dart';

class RecruitmentJobDetailsScreen extends StatelessWidget {
  const RecruitmentJobDetailsScreen({super.key, required this.job});

  final RecruitmentJob job;

  Color _getJobTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'full-time':
        return Colors.green;
      case 'part-time':
        return Colors.blue;
      case 'remote':
        return Colors.purple;
      case 'freelance':
      case 'freelancer':
        return Colors.teal;
      case 'one-time':
        return Colors.amber;
      case 'internship':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  String _translateLabel(String label, bool isAr) {
    if (!isAr) return label;
    final low = label.trim().toLowerCase();
    switch (low) {
      case 'full-time':
      case 'full time':
        return 'دوام كامل';
      case 'part-time':
      case 'part time':
        return 'دوام جزئي';
      case 'freelance':
      case 'freelancer':
        return 'عمل حر';
      case 'remote':
        return 'عن بعد';
      case 'internship':
        return 'تدريب';
      case 'one-time':
      case 'one time':
        return 'مرة واحدة';
      case 'service':
      case 'services':
        return 'خدمة';
      case 'technical':
        return 'تقني';
      case 'non-technical':
        return 'غير تقني';
      default:
        return label;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      appBar: AppBar(title: Text(isAr ? 'تفاصيل الوظيفة' : 'Job Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            job.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundImage: job.companyLogoUrl != null ? getAppImageProvider(job.companyLogoUrl!) : null,
                child: job.companyLogoUrl == null
                    ? const Icon(Icons.business, size: 14)
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(job.companyName)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isAr ? 'مطلوب ${job.capacity} أشخاص' : 'Hiring ${job.capacity} people',
                style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
              ),
              Text(
                isAr 
                  ? 'تم قبول ${job.acceptedCount} من ${job.capacity}' 
                  : '${job.acceptedCount} / ${job.capacity} Accepted',
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: job.capacity > 0 ? (job.acceptedCount / job.capacity).clamp(0.0, 1.0) : 0,
              backgroundColor: Theme.of(context).dividerColor.withValues(alpha: 0.1),
              color: job.acceptedCount >= job.capacity ? Colors.green : Theme.of(context).colorScheme.primary,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...job.type.split(RegExp(r'[•,;]')).map((t) {
                final type = t.trim();
                if (type.isEmpty) return const SizedBox.shrink();
                final color = _getJobTypeColor(type);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _translateLabel(type, isAr),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 12),
          if (job.tags.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              children: job.tags
                  .where((tag) => tag.trim().toLowerCase() != 'technical')
                  .map((e) => Chip(label: Text(_translateLabel(e, isAr))))
                  .toList(),
            ),
            const SizedBox(height: 12),
          ],
          if (job.classification.toLowerCase() != 'services' && job.classification.toLowerCase() != 'service') ...[
            Text(isAr ? 'الراتب: ${job.salaryRange}' : 'Salary: ${job.salaryRange}'),
          ],
          const SizedBox(height: 24),

          if (job.description.trim().isNotEmpty) ...[
            Text(
              isAr ? 'نظرة عامة' : 'Role Overview',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(job.description),
            const SizedBox(height: 24),
          ],

          if (job.responsibilities.isNotEmpty) ...[
            Text(
              isAr ? 'المسؤوليات' : 'Responsibilities',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...job.responsibilities.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(child: Text(item)),
                ],
              ),
            )),
            const SizedBox(height: 24),
          ],

          if (job.qualifications.isNotEmpty) ...[
            Text(
              isAr ? 'المؤهلات' : 'Qualifications',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...job.qualifications.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(child: Text(item)),
                ],
              ),
            )),
            const SizedBox(height: 24),
          ],

          if (job.benefits.isNotEmpty) ...[
            Text(
              isAr ? 'المميزات' : 'Benefits',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...job.benefits.map((item) {
              final parts = item.split(':::');
              final title = parts[0];
              final desc = parts.length > 1 ? parts[1] : '';
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          if (desc.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              desc,
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 18),
          AppButton(
            label: isAr ? 'قدّم الآن' : 'Apply',
            backgroundColor: const Color(0xFF4A6ED1),
            onPressed: () => Navigator.of(context).pushNamed(
              AppRoutes.userJobApplication,
              arguments: job,
            ),
          ),
        ],
      ),
    );
  }
}
