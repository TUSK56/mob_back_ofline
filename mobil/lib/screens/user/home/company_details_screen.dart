import 'package:flutter/material.dart';
import '../../../shared/l10n/app_localizations.dart';
import '../../../shared/state/recruitment_sync_store.dart';
import '../../../shared/utils/image_helper.dart';
import '../../../app/router/app_router.dart';
import '../../../shared/widgets/app_button.dart';

class CompanyDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> company;

  const CompanyDetailsScreen({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final store = RecruitmentSyncStore.instance;
    final theme = Theme.of(context);
    
    // Filter jobs for this specific company
    final companyJobs = store.jobs.where((job) => 
      job.companyName.trim().toLowerCase() == company['name'].toString().trim().toLowerCase()
    ).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(isAr ? Icons.arrow_back_ios_new : Icons.arrow_back_ios, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          t.tr(en: 'Company Details', ar: 'تفاصيل الشركة'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                    ),
                    child: Center(
                      child: getAppImageProvider(company['logoUrl']?.toString()) != null
                          ? CircleAvatar(radius: 40, backgroundImage: getAppImageProvider(company['logoUrl']?.toString()))
                          : Icon(Icons.business, color: theme.colorScheme.primary, size: 48),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    company['name'] as String,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      company['industry'] as String,
                      style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // About Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.tr(en: 'About Company', ar: 'عن الشركة'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    company['description'] as String,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Jobs List Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    t.tr(en: 'Open Vacancies', ar: 'الوظائف المتاحة'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${companyJobs.length} ${isAr ? "وظيفة" : "Jobs"}',
                    style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            if (companyJobs.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.work_off_outlined, size: 64, color: theme.dividerColor.withValues(alpha: 0.2)),
                      const SizedBox(height: 16),
                      Text(
                        t.tr(en: 'No jobs available right now', ar: 'لا توجد وظائف متاحة حالياً'),
                        style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.38)),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: companyJobs.length,
                itemBuilder: (context, index) {
                  final job = companyJobs[index];
                  return _buildJobCard(context, job, t);
                },
              ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCard(BuildContext context, RecruitmentJob job, AppLocalizations t) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: theme.cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.userJobDetails, arguments: job),
        borderRadius: BorderRadius.circular(20),
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
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    job.salaryRange,
                    style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildIconText(theme, Icons.location_on_outlined, job.location),
                  const SizedBox(width: 16),
                  _buildIconText(theme, Icons.work_outline, job.type),
                ],
              ),
              const SizedBox(height: 20),
              AppButton(
                label: t.tr(en: 'Apply Now', ar: 'قدّم الآن'),
                backgroundColor: const Color(0xFF4A6ED1),
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.userJobApplication, arguments: job),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconText(ThemeData theme, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
        ),
      ],
    );
  }
}
