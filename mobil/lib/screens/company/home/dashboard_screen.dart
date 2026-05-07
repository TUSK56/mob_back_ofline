// Company home: KPIs, shortcuts, and recent jobs.

import 'package:flutter/material.dart';

import '../../../app/router/app_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../shared/l10n/app_localizations.dart';
import '../../../shared/models/job.dart';
import '../../../shared/state/company_store.dart';
import '../../../shared/services/recruitment_sync_service.dart';
import '../../../shared/state/recruitment_sync_store.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/section_title.dart';
import '../widgets/company_app_bar_title.dart';
import '../widgets/company_bottom_nav.dart';

class CompanyDashboardScreen extends StatefulWidget {
  const CompanyDashboardScreen({super.key});

  @override
  State<CompanyDashboardScreen> createState() => _CompanyDashboardScreenState();
}

class _CompanyDashboardScreenState extends State<CompanyDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Always pull fresh data from the server when the dashboard is shown.
    RecruitmentSyncService.instance.startPolling();
  }

  @override
  Widget build(BuildContext context) {
    final companyStore = CompanyStore.instance;
    return ListenableBuilder(
      listenable: Listenable.merge([
        companyStore,
        RecruitmentSyncStore.instance,
      ]),
      builder: (context, _) {
        return AppScaffold(
          titleWidget: const CompanyAppBarIdentity(),
          showBack: false,
          centerTitle: false,
          showAppBarDivider: true,
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final companyId = companyStore.companyId.trim();
                  final allRemoteJobs = RecruitmentSyncStore.instance.jobs.toList();
                  // Strictly show only this company's jobs. Never fall back to all jobs.
                  final allJobs = (companyId.isNotEmpty
                          ? allRemoteJobs
                              .where((j) => j.companyId.trim() == companyId)
                              .toList()
                          : <RecruitmentJob>[])
                    ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
                  final t = AppLocalizations.of(context);

                  return ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: constraints.maxWidth < 400 ? 12 : 16,
                      vertical: 16,
                    ),
                    children: [
                      SectionTitle(t.jobUpdates),
                      const SizedBox(height: 10),
                      ...allJobs.map(
                        (j) =>
                            _JobUpdateCard(job: j, companyStore: companyStore),
                      ),
                      if (allJobs.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: Text(
                            t.noJobsYet,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      const SizedBox(height: 10),
                    ],
                  );
                },
              ),
            ),
          ),
          bottomNavigationBar: const CompanyBottomNav(current: CompanyTab.home),
        );
      },
    );
  }
}

class _JobUpdateCard extends StatelessWidget {
  const _JobUpdateCard({required this.job, required this.companyStore});

  final RecruitmentJob job;
  final CompanyStore companyStore;

  Color _getJobTypeColor(String type) {
    switch (type.toLowerCase().trim()) {
      case 'full-time':
        return AppColors.success;
      case 'part-time':
        return AppColors.lightPrimary;
      case 'remote':
        return AppColors.info;
      case 'freelance':
        return AppColors.lightAccent;
      case 'one-time':
        return AppColors.warning;
      case 'internship':
        return const Color(0xFF8B5CF6);
      default:
        return AppColors.lightMuted;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'technical':
      case 'تقني':
        return const Color(0xFF3B82F6);
      case 'non-technical':
      case 'غير تقني':
        return const Color(0xFFEC4899);
      case 'services':
      case 'خدمات':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final syncStore = RecruitmentSyncStore.instance;

    final appliedCount = syncStore.applications
        .where((a) => a.jobId == job.id)
        .length;
    final hiredCount = syncStore.applications
        .where(
          (a) => a.jobId == job.id && a.status.toLowerCase().contains('hire'),
        )
        .length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed(
          AppRoutes.companyJobDetails,
          arguments: Job(
            id: job.id,
            companyId: job.companyId,
            title: job.title,
            companyName: job.companyName,
            location: job.location,
            employmentType: job.type,
            classification: job.classification,
            salaryRange: job.salaryRange,
            description: job.description,
            responsibilities: job.responsibilities,
            niceToHaves: job.niceToHaves,
            qualifications: job.qualifications,
            benefits: job.benefits
                .map((b) => JobBenefit(title: b, description: ''))
                .toList(),
            tags: job.tags,
            appliedCount: appliedCount,
            requiredCount: job.capacity,
            acceptedCount: hiredCount,
            status: job.status,
            createdAt: job.publishedAt,
          ),
        ),
        borderRadius: BorderRadius.circular(18),
        child: Card(
          elevation: 0,
          color: Theme.of(context).cardTheme.color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.05),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        job.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        onSelected: (val) async {
                          final newStatus = val == 'close' ? 'Closed' : 'Open';
                          final msg = val == 'close'
                              ? (t.isAr ? 'تم إغلاق الوظيفة' : 'Job closed')
                              : (t.isAr
                                    ? 'تم إعادة فتح الوظيفة'
                                    : 'Job reopened');
                          try {
                            if (val == 'reopen') {
                              await RecruitmentSyncService.instance
                                  .reopenJobAndResetAccepted(job.id);
                            } else {
                              await RecruitmentSyncService.instance.updateJob(
                                jobId: job.id,
                                title: job.title,
                                companyName: job.companyName,
                                location: job.location,
                                salaryRange: job.salaryRange,
                                type: job.type,
                                description: job.description,
                                responsibilities: job.responsibilities,
                                qualifications: job.qualifications,
                                niceToHaves: job.niceToHaves,
                                benefits: job.benefits,
                                classification: job.classification,
                                tags: job.tags,
                                requiredCount: job.capacity,
                                status: newStatus,
                              );
                            }
                            if (context.mounted) {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(msg)));
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          if (job.status == 'Open')
                            PopupMenuItem(
                              value: 'close',
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.lock_outline,
                                    size: 18,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    t.isAr ? 'إغلاق الوظيفة' : 'Close Job',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            )
                          else
                            PopupMenuItem(
                              value: 'reopen',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.lock_open_outlined,
                                    size: 18,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    t.isAr ? 'إعادة الفتح' : 'Reopen',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final tTrim in [
                      ...job.type.split(RegExp(r'[•,;]')),
                      job.classification,
                      ...job.tags
                    ].map((t) => t.trim()).where((t) => t.isNotEmpty && t.toLowerCase() != 'general').toSet())
                      Builder(
                        builder: (context) {
                          final color = _getJobTypeColor(tTrim);
                          final isClassification = tTrim.toLowerCase() == job.classification.toLowerCase();
                          return Container(
                            margin: const EdgeInsets.only(right: 8, bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isClassification ? _getCategoryColor(tTrim) : color,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: (isClassification ? _getCategoryColor(tTrim) : color).withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              tTrim,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                ListenableBuilder(
                  listenable: syncStore,
                  builder: (context, _) {
                    final currentHiredCount = syncStore.applications
                        .where((a) => a.jobId == job.id && a.status.toLowerCase().contains('hire'))
                        .length;
                    final requiredCount = job.capacity > 0 ? job.capacity : 1;
                    final progress = (currentHiredCount / requiredCount).clamp(0.0, 1.0);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              t.hiredProgressMsg(currentHiredCount, requiredCount),
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                            ),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: TextStyle(
                                color: progress >= 1.0
                                    ? Colors.green
                                    : Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Theme.of(
                              context,
                            ).dividerColor.withOpacity(0.05),
                            color: progress >= 1.0
                                ? Colors.green
                                : Theme.of(context).colorScheme.primary,
                            minHeight: 8,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
