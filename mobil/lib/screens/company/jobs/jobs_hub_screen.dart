// List and search all jobs for the signed-in company.

import 'package:flutter/material.dart';

import '../../../app/router/app_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../shared/l10n/app_localizations.dart';
import '../../../shared/state/company_store.dart';
import '../../../shared/state/recruitment_sync_store.dart';
import '../../../shared/services/recruitment_sync_service.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../widgets/company_app_bar_actions.dart';
import '../widgets/company_bottom_nav.dart';

class CompanyJobsHubScreen extends StatefulWidget {
  const CompanyJobsHubScreen({super.key});

  @override
  State<CompanyJobsHubScreen> createState() => _CompanyJobsHubScreenState();
}

class _CompanyJobsHubScreenState extends State<CompanyJobsHubScreen> {
  final Set<String> _selectedStatuses = {};
  final Set<String> _selectedTypes = {};

  @override
  void initState() {
    super.initState();
    // Sync jobs from backend
    RecruitmentSyncService.instance.startPolling();
  }

  @override
  Widget build(BuildContext context) {
    final companyStore = CompanyStore.instance;
    final t = AppLocalizations.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return AppScaffold(
      title: t.job,
      showBack: false,
      leading: const CompanyProfileLeading(),
      actions: const [CompanyAppBarActions()],
      showAppBarDivider: true,
      bottomNavigationBar: const CompanyBottomNav(
        current: CompanyTab.applicants,
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([
          companyStore,
          RecruitmentSyncStore.instance,
        ]),
        builder: (context, _) {
          final companyId = companyStore.companyId.trim();
          final allRemoteJobs = RecruitmentSyncStore.instance.jobs.toList();
          // Strictly show only jobs owned by the signed-in company.
          // Never fall back to showing all companies' jobs.
          final jobs = (companyId.isNotEmpty
                  ? allRemoteJobs.where((j) => j.companyId.trim() == companyId).toList()
                  : <RecruitmentJob>[])
            ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

          final filteredJobs = jobs.where((j) {
            final matchesStatus =
                _selectedStatuses.isEmpty ||
                _selectedStatuses.contains(j.status);
            final matchesType =
                _selectedTypes.isEmpty || _selectedTypes.contains(j.type);
            return matchesStatus && matchesType;
          }).toList();

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Column(
                children: [
                  _buildFilterBar(isAr),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        ...filteredJobs.map((j) {
                          final count = RecruitmentSyncStore
                              .instance
                              .applications
                              .where((a) => a.jobId == j.id)
                              .length;
                          final isOpen = j.status == 'Open';

                            return Card(
                              color: Theme.of(context).cardTheme.color,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                                side: BorderSide(
                                  color: Theme.of(context).dividerColor.withOpacity(0.05),
                                ),
                              ),
                              margin: const EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () => Navigator.of(context).pushNamed(AppRoutes.companyJobDetails, arguments: j),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Title and Actions
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              j.title,
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          PopupMenuButton<String>(
                                              icon: Icon(Icons.more_vert,
                                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                                              onSelected: (val) async {
                                                final newStatus = val == 'close' ? 'Closed' : 'Open';
                                                final msg = val == 'close'
                                                    ? (t.isAr ? 'تم إغلاق الوظيفة' : 'Job closed')
                                                    : (t.isAr ? 'تم إعادة فتح الوظيفة' : 'Job reopened');
                                                try {
                                                  if (val == 'reopen') {
                                                    await RecruitmentSyncService.instance
                                                        .reopenJobAndResetAccepted(j.id);
                                                  } else {
                                                    await RecruitmentSyncService.instance.updateJob(
                                                      jobId: j.id,
                                                      title: j.title,
                                                      companyName: j.companyName,
                                                      location: j.location,
                                                      salaryRange: j.salaryRange,
                                                      type: j.type,
                                                      description: j.description,
                                                      responsibilities: j.responsibilities,
                                                      qualifications: j.qualifications,
                                                      niceToHaves: j.niceToHaves,
                                                      benefits: j.benefits,
                                                      classification: j.classification,
                                                      tags: j.tags,
                                                      requiredCount: j.capacity,
                                                      status: newStatus,
                                                    );
                                                  }
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text(msg)),
                                                    );
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
                                                if (j.status == 'Open')
                                                  PopupMenuItem(
                                                    value: 'close',
                                                    child: Row(
                                                      children: [
                                                        const Icon(Icons.lock_outline, size: 18, color: Colors.red),
                                                        const SizedBox(width: 8),
                                                        Text(t.isAr ? 'إغلاق الوظيفة' : 'Close Job',
                                                            style: const TextStyle(color: Colors.red)),
                                                      ],
                                                    ),
                                                  )
                                                else
                                                  PopupMenuItem(
                                                    value: 'reopen',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.lock_open_outlined, size: 18,
                                                            color: Theme.of(context).colorScheme.primary),
                                                        const SizedBox(width: 8),
                                                        Text(t.isAr ? 'إعادة الفتح' : 'Reopen',
                                                            style: TextStyle(
                                                                color: Theme.of(context).colorScheme.primary)),
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      // Tags (Deduplicated)
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          ...[
                                            ...j.type.split(RegExp(r'[•,;]')),
                                            j.classification,
                                            ...j.tags
                                          ].map((t) => t.trim())
                                           .where((t) => t.isNotEmpty && t.toLowerCase() != 'general')
                                           .toSet()
                                           .toList()
                                           .map((tTrim) {
                                            final color = _getJobTypeColor(tTrim);
                                            final isClassification = tTrim.toLowerCase() == j.classification.toLowerCase();
                                            
                                            return Container(
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
                                          }),
                                        ],
                                      ),
                                    const SizedBox(height: 12),
                                    // Hiring stats row
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.people_outline,
                                          size: 16,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '$count ${isAr ? 'متقدمين' : 'applicants'}',
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const Spacer(),
                                        if (j.capacity > 0)
                                          Text(
                                            isAr
                                                ? 'تم القبول: ${j.acceptedCount} / المطلوب: ${j.capacity}'
                                                : 'Accepted: ${j.acceptedCount} / Required: ${j.capacity}',
                                            style: TextStyle(
                                              color:
                                                  j.acceptedCount >= j.capacity
                                                  ? Colors.green.shade700
                                                  : Colors.blue.shade700,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        if (j.location.isNotEmpty) ...[
                                          Icon(
                                            Icons.location_on_outlined,
                                            size: 16,
                                            color: Colors.grey.shade600,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            j.location,
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isOpen
                                                ? Colors.green.withOpacity(0.1)
                                                : Colors.grey.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            isOpen
                                                ? (isAr ? 'مفتوح' : 'Open')
                                                : (isAr ? 'مغلق' : 'Closed'),
                                            style: TextStyle(
                                              color: isOpen
                                                  ? Colors.green.shade700
                                                  : Colors.grey.shade700,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        if (filteredJobs.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 14),
                            child: Center(
                              child: Text(
                                t.noJobsYet,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterBar(bool isAr) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _FilterChip(
            label: isAr ? 'مفتوح' : 'Open',
            isSelected: _selectedStatuses.contains('Open'),
            onChanged: (val) => _toggleFilter(_selectedStatuses, 'Open', val),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: isAr ? 'مغلق' : 'Closed',
            isSelected: _selectedStatuses.contains('Closed'),
            onChanged: (val) => _toggleFilter(_selectedStatuses, 'Closed', val),
          ),
          Container(
            height: 24,
            width: 1,
            color: Colors.grey.withOpacity(0.3),
            margin: const EdgeInsets.symmetric(horizontal: 12),
          ),
          _FilterChip(
            label: isAr ? 'دوام كامل' : 'Full-Time',
            isSelected: _selectedTypes.contains('Full-Time'),
            onChanged: (val) => _toggleFilter(_selectedTypes, 'Full-Time', val),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: isAr ? 'دوام جزئي' : 'Part-Time',
            isSelected: _selectedTypes.contains('Part-Time'),
            onChanged: (val) => _toggleFilter(_selectedTypes, 'Part-Time', val),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: isAr ? 'عمل حر (Freelance)' : 'Freelance',
            isSelected: _selectedTypes.contains('Freelance'),
            onChanged: (val) => _toggleFilter(_selectedTypes, 'Freelance', val),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: isAr ? 'تدريب (Internship)' : 'Internship',
            isSelected: _selectedTypes.contains('Internship'),
            onChanged: (val) =>
                _toggleFilter(_selectedTypes, 'Internship', val),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: isAr ? 'عمل لمرة واحدة' : 'One-time',
            isSelected: _selectedTypes.contains('One-time'),
            onChanged: (val) => _toggleFilter(_selectedTypes, 'One-time', val),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: isAr ? 'عن بعد (Remote)' : 'Remote',
            isSelected: _selectedTypes.contains('Remote'),
            onChanged: (val) => _toggleFilter(_selectedTypes, 'Remote', val),
          ),
        ],
      ),
    );
  }

  void _toggleFilter(Set<String> set, String value, bool? selected) {
    setState(() {
      if (selected == true) {
        set.add(value);
      } else {
        set.remove(value);
      }
    });
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onChanged,
  });

  final String label;
  final bool isSelected;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isSelected),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.withOpacity(0.3),
            width: 1,
          ),
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
              : Colors.transparent,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: isSelected,
                onChanged: onChanged,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: BorderSide(color: Colors.grey.withOpacity(0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension _JobHelpers on _CompanyJobsHubScreenState {
  Color _getJobTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'full-time':
      case 'دوام كامل':
        return AppColors.success;
      case 'part-time':
      case 'دوام جزئي':
        return AppColors.lightPrimary;
      case 'freelance':
      case 'عمل حر':
        return AppColors.lightAccent;
      case 'internship':
      case 'تدريب':
        return const Color(0xFF8B5CF6);
      case 'remote':
      case 'عن بعد':
        return AppColors.info;
      case 'one-time':
      case 'عمل لمرة واحدة':
        return AppColors.warning;
      default:
        return const Color(0xFF6B7280);
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
}
