// Tabular list of applicants for a job.

import 'package:flutter/material.dart';

import '../../../app/router/app_router.dart';
import '../../../constants/app_images.dart';
import '../../../shared/models/applicant.dart';
import '../../../shared/models/job.dart';
import '../../../shared/state/recruitment_sync_store.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../widgets/company_app_bar_actions.dart';
import '../widgets/company_bottom_nav.dart';

class CompanyJobApplicantsTableViewScreen extends StatefulWidget {
  const CompanyJobApplicantsTableViewScreen({super.key, required this.job});

  final Job job;

  @override
  State<CompanyJobApplicantsTableViewScreen> createState() =>
      _CompanyJobApplicantsTableViewScreenState();
}

class _CompanyJobApplicantsTableViewScreenState
    extends State<CompanyJobApplicantsTableViewScreen> {
  final _searchController = TextEditingController();

  static const _stageOptions = <String>[
    'Applied',
    'In Review',
    'Shortlisted',
    'Waitlist',
    'Hired',
    'Declined',
  ];

  late Set<String> _selectedStages;

  @override
  void initState() {
    super.initState();
    _selectedStages = _stageOptions.toSet();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesSearch(Applicant a) {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return true;
    return a.fullName.toLowerCase().contains(q) ||
        a.role.toLowerCase().contains(q);
  }

  bool _matchesStages(Applicant a) {
    return _selectedStages.contains(a.stage);
  }

  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        final temp = _selectedStages.toSet();
        return StatefulBuilder(
          builder: (ctx, setInnerState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ..._stageOptions.map(
                    (s) => CheckboxListTile(
                      dense: true,
                      value: temp.contains(s),
                      onChanged: (v) {
                        setInnerState(() {
                          if (v == true) {
                            temp.add(s);
                          } else {
                            temp.remove(s);
                          }
                        });
                      },
                      title: Text(s),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              Navigator.of(ctx).pop(_stageOptions.toSet()),
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.of(ctx).pop(temp),
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            );
          },
        );
      },
    );

    if (result == null) return;
    setState(() => _selectedStages = result);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: RecruitmentSyncStore.instance,
      builder: (context, _) {
        final allApps = RecruitmentSyncStore.instance.applications
            .where(
              (app) =>
                  app.jobId == widget.job.id || widget.job.id == 'fallback',
            )
            .toList();

        final filtered = allApps
            .map(
              (app) => Applicant(
                id: app.id,
                fullName: app.userName,
                role: app.jobTitle,
                rating: 4.5, // Default rating
                stage: app.status,
                email: app.email ?? 'candidate@jobito.com',
                phone: app.phone ?? '+20 123 456 789',
                location: app.location ?? 'Egypt',
                appliedDateLabel: 'Today',
                gender: app.gender,
                birthDate: app.birthDate,
                languages: app.languages,
                about: app.about,
                experienceYears: app.experienceYears,
                education: app.education,
                skills: app.skills,
                hasCv: app.hasCv,
                cvUrl: app.cvUrl,
                cvFileName: app.cvFileName,
                jobId: app.jobId,
              ),
            )
            .where((a) => _matchesStages(a) && _matchesSearch(a))
            .toList();

        return AppScaffold(
          title: widget.job.title,
          showBack: false,
          leading: const CompanyProfileLeading(),
          actions: const [CompanyAppBarActions()],
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.isEmpty ? 2 : filtered.length + 1,
            itemBuilder: (_, i) {
              if (i == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 420;
                      if (isNarrow) {
                        return Column(
                          children: [
                            TextField(
                              controller: _searchController,
                              onChanged: (_) => setState(() {}),
                              decoration: const InputDecoration(
                                hintText: 'Search applicants',
                                prefixIcon: Icon(Icons.search),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _openFilterSheet,
                                icon: const Icon(Icons.filter_list),
                                label: const Text('Filter'),
                              ),
                            ),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (_) => setState(() {}),
                              decoration: const InputDecoration(
                                hintText: 'Search applicants',
                                prefixIcon: Icon(Icons.search),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: _openFilterSheet,
                            icon: const Icon(Icons.filter_list),
                            label: const Text('Filter'),
                          ),
                        ],
                      );
                    },
                  ),
                );
              }

              if (filtered.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: Text(
                    'No applicants',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                );
              }

              final a = filtered[i - 1];
              return _ApplicantRow(
                applicant: a,
                onTap: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.companyApplicantDetailsProfile,
                    arguments: a,
                  );
                },
                avatarIndex: i - 1,
              );
            },
          ),
          bottomNavigationBar: const CompanyBottomNav(
            current: CompanyTab.applicants,
          ),
        );
      },
    );
  }
}

class _ApplicantRow extends StatelessWidget {
  const _ApplicantRow({
    required this.applicant,
    required this.onTap,
    required this.avatarIndex,
  });

  final Applicant applicant;
  final VoidCallback onTap;
  final int avatarIndex;

  static const _avatars = [
    AppImages.companyProfile1,
    AppImages.companyProfile2,
    AppImages.companyProfile3,
    AppImages.companyProfile4,
    AppImages.companyProfile5,
    AppImages.companyProfile6,
    AppImages.companyProfile7,
  ];

  Color _stageColor(BuildContext context) {
    final stage = applicant.stage.toLowerCase();
    if (stage.contains('declin')) return Theme.of(context).colorScheme.error;
    if (stage.contains('hire')) return Colors.tealAccent.shade700;
    return Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final chipColor = _stageColor(context);
    final avatar = _avatars[avatarIndex % _avatars.length];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withOpacity(0.2),
          backgroundImage: AssetImage(avatar),
        ),
        title: Text(applicant.fullName),
        subtitle: Text(
          '${applicant.appliedDateLabel} • ⭐ ${applicant.rating.toStringAsFixed(1)}',
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: chipColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: chipColor.withOpacity(0.35)),
          ),
          child: Text(applicant.stage),
        ),
        onTap: onTap,
      ),
    );
  }
}
