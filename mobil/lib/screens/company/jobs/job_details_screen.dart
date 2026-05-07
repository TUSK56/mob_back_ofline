// Full job posting details and management actions.

import 'package:flutter/material.dart';

import '../../../app/router/app_router.dart';
import '../../../shared/l10n/app_localizations.dart';
import '../../../shared/models/job.dart';
import '../../../shared/services/recruitment_sync_service.dart';
import '../../../shared/state/company_store.dart';
import '../../../shared/state/recruitment_sync_store.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/section_title.dart';
import '../widgets/company_bottom_nav.dart';

class CompanyJobDetailsScreen extends StatefulWidget {
  const CompanyJobDetailsScreen({super.key, required this.job});

  final Job job;

  @override
  State<CompanyJobDetailsScreen> createState() =>
      _CompanyJobDetailsScreenState();
}

class _CompanyJobDetailsScreenState extends State<CompanyJobDetailsScreen> {
  bool _deleting = false;
  bool _reopening = false;

  Job get _job {
    final storedJob = CompanyStore.instance.jobById(widget.job.id);
    if (storedJob.id == widget.job.id) {
      return storedJob;
    }
    return widget.job;
  }

  Future<void> _reopenJob() async {
    final t = AppLocalizations.of(context);
    setState(() => _reopening = true);
    try {
      final job = _job;
      await RecruitmentSyncService.instance.reopenJobAndResetAccepted(job.id);
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t.isAr ? 'تم إعادة فتح الوظيفة بنجاح' : 'Job reopened successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _reopening = false);
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Job',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Are you sure you want to delete "${_job.title}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFB91C1C),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _deleting = true);
    try {
      await RecruitmentSyncService.instance.deleteJob(widget.job.id);
      if (!mounted) return;
      Navigator.of(context).pop(); // Go back to jobs list
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete job: $e')));
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final job = _job;
    return AppScaffold(
      title: job.title,
      showBack: true,
      actions: [
        IconButton(
          onPressed: () => Navigator.of(
            context,
          ).pushNamed(AppRoutes.companyApplicantsTable, arguments: job),
          icon: const Icon(Icons.groups_outlined),
        ),
        IconButton(
          onPressed: () => Navigator.of(
            context,
          ).pushNamed(AppRoutes.companyJobAnalytics, arguments: job),
          icon: const Icon(Icons.bar_chart_outlined),
        ),
      ],
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Status Banner ─────────────────────────────────────────────
              if (job.status.toLowerCase() == 'closed')
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lock_outline,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          t.isAr
                              ? 'هذه الوظيفة مغلقة حالياً. اضغط على "إعادة الفتح" لاستقبال طلبات جديدة.'
                              : 'This job is currently closed. Tap "Reopen" to start accepting new applicants.',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              SectionTitle(
                t.descriptionSection,
                trailing: IconButton(
                  tooltip: t.edit,
                  onPressed: () => _editJob(context, job),
                  icon: const Icon(Icons.edit_outlined),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                job.description.isEmpty ? t.noDescriptionYet : job.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              SectionTitle(t.responsibilities),
              const SizedBox(height: 10),
              _Bullets(items: job.responsibilities),
              const SizedBox(height: 16),
              SectionTitle(t.niceToHavesSection),
              const SizedBox(height: 10),
              _Bullets(items: job.niceToHaves),
              const SizedBox(height: 16),
              SectionTitle(t.qualifications),
              const SizedBox(height: 10),
              _Bullets(items: job.qualifications),
              const SizedBox(height: 16),
              SectionTitle(t.benefits),
              const SizedBox(height: 10),
              if (job.benefits.isEmpty)
                Text(
                  t.notYet,
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.4),
                  ),
                )
              else
                Column(
                  children: job.benefits
                      .map(
                        (b) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 20,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      b.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (b.description.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        b.description,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              const SizedBox(height: 16),
              SectionTitle(t.aboutThisRole),
              const SizedBox(height: 10),
              _InfoRow(label: t.salaryLabel, value: job.salaryRange),
              _InfoRow(label: t.jobTypeLabel, value: job.employmentType),
              _InfoRow(label: t.categoryLabel, value: job.classification),
              const SizedBox(height: 18),
              _JobApplicantsSection(jobId: job.id),
              const SizedBox(height: 14),
              AppButton(
                label: t.openFullTable,
                onPressed: () => Navigator.of(
                  context,
                ).pushNamed(AppRoutes.companyApplicantsTable, arguments: job),
              ),
              const SizedBox(height: 16),
              // ── Reopen Button (only for closed jobs) ─────────────────────
              if (job.status.toLowerCase() == 'closed')
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.85),
                            Theme.of(context).colorScheme.primary,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(25),
                          bottomLeft: Radius.circular(70),
                          topRight: Radius.circular(70),
                          bottomRight: Radius.circular(25),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _reopening ? null : _reopenJob,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(25),
                              bottomLeft: Radius.circular(70),
                              topRight: Radius.circular(70),
                              bottomRight: Radius.circular(25),
                            ),
                          ),
                        ),
                        icon: _reopening
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.lock_open_outlined, size: 20),
                        label: Text(
                          _reopening
                              ? (t.isAr
                                    ? 'جاري إعادة الفتح...'
                                    : 'Reopening...')
                              : (t.isAr ? 'إعادة فتح الوظيفة' : 'Reopen Job'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              // ── Delete Job Button ─────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF7F1D1D),
                        Color(0xFFB91C1C),
                        Color(0xFFEF4444),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(70),
                      bottomLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                      bottomRight: Radius.circular(70),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFB91C1C).withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _deleting ? null : () => _confirmDelete(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(70),
                          bottomLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                          bottomRight: Radius.circular(70),
                        ),
                      ),
                    ),
                    icon: _deleting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.delete_outline_rounded, size: 20),
                    label: Text(
                      _deleting ? 'Deleting...' : 'Delete Job',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CompanyBottomNav(
        current: CompanyTab.applicants,
      ),
    );
  }

  Future<void> _editJob(BuildContext context, Job job) async {
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.companyPostJobStep1, arguments: job);
  }
}

class _Bullets extends StatelessWidget {
  const _Bullets({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    if (items.isEmpty) {
      return Text(t.noItemsYet, style: Theme.of(context).textTheme.bodyMedium);
    }
    return Column(
      children: items
          .map(
            (text) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Icon(Icons.circle, size: 6),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(text)),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _JobApplicantsSection extends StatelessWidget {
  const _JobApplicantsSection({required this.jobId});

  final String jobId;

  @override
  Widget build(BuildContext context) {
    final applicants = RecruitmentSyncStore.instance.applications
        .where((a) => a.jobId == jobId)
        .toList();

    if (applicants.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'No applicants yet',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: applicants
            .take(4)
            .map(
              (a) => ListTile(
                dense: true,
                title: Text(a.userName.isEmpty ? a.jobTitle : a.userName),
                subtitle: Text(a.status),
                trailing: const Icon(Icons.chevron_right),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 420;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: isNarrow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                SizedBox(width: 110, child: Text(label)),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
