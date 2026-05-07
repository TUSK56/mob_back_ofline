import 'package:flutter/material.dart';
import '../../../../shared/state/recruitment_sync_store.dart';
import '../../../../shared/utils/image_helper.dart';

class CompanyPublicProfile {
  final String name;
  final String industry;
  final String? logoUrl;
  final String aboutEn;
  final String aboutAr;
  final String website;
  final String staff;
  final String classification;
  final List<String> locations;
  final List<String> techStack;
  final List<String> benefits;
  final int foundedYear;
  final List<RecruitmentJob> jobs;

  const CompanyPublicProfile({
    required this.name,
    required this.industry,
    this.logoUrl,
    required this.aboutEn,
    required this.aboutAr,
    required this.website,
    required this.staff,
    required this.classification,
    required this.locations,
    required this.techStack,
    required this.benefits,
    required this.foundedYear,
    required this.jobs,
  });
}

class CompanyPublicProfileScreen extends StatelessWidget {
  final CompanyPublicProfile company;

  const CompanyPublicProfileScreen({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final about = isAr ? company.aboutAr : company.aboutEn;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Hero App Bar
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: const Color(0xFF011931),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient Background
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF011931), Color(0xFF49769F)],
                      ),
                    ),
                  ),
                  // Company Logo + Name
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 80, 24, 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Logo
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: company.logoUrl != null
                                    ? Image(
                                        image: getAppImageProvider(company.logoUrl)!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(
                                          Icons.business_rounded,
                                          size: 36,
                                          color: Color(0xFF49769F),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.business_rounded,
                                        size: 36,
                                        color: Color(0xFF49769F),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    company.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  if (company.industry.isNotEmpty)
                                    Text(
                                      company.industry,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.75),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Stats Row
                  Row(
                    children: [
                      if (company.staff.isNotEmpty)
                        _buildStatChip(
                          icon: Icons.people_outline,
                          label: company.staff,
                          color: const Color(0xFF49769F),
                        ),
                      if (company.staff.isNotEmpty) const SizedBox(width: 10),
                      if (company.foundedYear > 0)
                        _buildStatChip(
                          icon: Icons.calendar_today_outlined,
                          label: '${isAr ? 'تأسست' : 'Est.'} ${company.foundedYear}',
                          color: const Color(0xFF49769F),
                        ),
                      if (company.foundedYear > 0) const SizedBox(width: 10),
                      if (company.classification.isNotEmpty)
                        _buildStatChip(
                          icon: Icons.category_outlined,
                          label: company.classification == 'Technical'
                              ? (isAr ? 'تقني' : 'Technical')
                              : (isAr ? 'غير تقني' : 'Non-Technical'),
                          color: const Color(0xFF49769F),
                        ),
                      if (company.classification.isNotEmpty) const SizedBox(width: 10),
                      _buildStatChip(
                        icon: Icons.work_outline,
                        label: isAr
                            ? '${company.jobs.length} وظيفة'
                            : '${company.jobs.length} Jobs',
                        color: const Color(0xFFFF7A2A),
                      ),
                    ],
                  ),

                  // About Section
                  if (about.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    _buildSectionTitle(isAr ? 'عن الشركة' : 'About Company'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.withOpacity(0.08)),
                      ),
                      child: Text(
                        about,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],

                  // Locations
                  if (company.locations.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSectionTitle(isAr ? 'المواقع' : 'Locations'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: company.locations
                          .map((loc) => _buildTag(
                                label: loc,
                                icon: Icons.location_on_outlined,
                                bgColor: const Color(0xFFF0F7FF),
                                textColor: const Color(0xFF49769F),
                              ))
                          .toList(),
                    ),
                  ],

                  // Tech Stack
                  if (company.techStack.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSectionTitle(isAr ? 'التقنيات المستخدمة' : 'Tech Stack'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: company.techStack
                          .map((tech) => _buildTag(
                                label: tech,
                                icon: Icons.code,
                                bgColor: const Color(0xFFF0FFF4),
                                textColor: Colors.green.shade700,
                              ))
                          .toList(),
                    ),
                  ],

                  // Benefits
                  if (company.benefits.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSectionTitle(isAr ? 'المزايا' : 'Benefits'),
                    const SizedBox(height: 12),
                    ...company.benefits.map(
                      (benefit) {
                        final parts = benefit.split(':::');
                        final title = parts[0];
                        final desc = parts.length > 1 ? parts[1] : '';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF49769F),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    if (desc.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        desc,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black.withOpacity(0.5),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],

                  // Open Jobs
                  if (company.jobs.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    _buildSectionTitle(
                      isAr ? 'الوظائف المتاحة' : 'Open Positions',
                    ),
                    const SizedBox(height: 12),
                    ...company.jobs.map(
                      (job) => _buildJobCard(context, job, isAr),
                    ),
                  ] else ...[
                    const SizedBox(height: 28),
                    _buildSectionTitle(isAr ? 'الوظائف المتاحة' : 'Open Positions'),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.work_off_outlined,
                              size: 48, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(
                            isAr ? 'لا توجد وظائف متاحة حالياً' : 'No open positions at the moment',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Color(0xFF011931),
      ),
    );
  }

  Widget _buildTag({required String label, required IconData icon, required Color bgColor, required Color textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildJobCard(BuildContext context, RecruitmentJob job, bool isAr) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            job.title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: Color(0xFF011931),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildJobMeta(Icons.location_on_outlined, job.location),
              const SizedBox(width: 16),
              _buildJobMeta(Icons.work_outline, job.type),
              if (job.salaryRange.isNotEmpty) ...[
                const SizedBox(width: 16),
                _buildJobMeta(Icons.attach_money, job.salaryRange),
              ],
            ],
          ),
          if (job.tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: job.tags.where((tag) => tag.trim().toLowerCase() != 'technical').take(3).map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F3FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(tag, style: const TextStyle(fontSize: 11, color: Color(0xFF49769F), fontWeight: FontWeight.w600)),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildJobMeta(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.black45),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}
