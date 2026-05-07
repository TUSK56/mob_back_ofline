import 'package:flutter/material.dart';
import '../setting/settings.dart';
import '../../../../shared/state/recruitment_sync_store.dart';
import '../../../../shared/state/company_store.dart';
import '../../../../shared/utils/image_helper.dart';
import 'company_public_profile_screen.dart';

class TradesmanBrowseCompaniesScreen extends StatefulWidget {
  const TradesmanBrowseCompaniesScreen({super.key});

  @override
  State<TradesmanBrowseCompaniesScreen> createState() =>
      _TradesmanBrowseCompaniesScreenState();
}

class _TradesmanBrowseCompaniesScreenState
    extends State<TradesmanBrowseCompaniesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedLocation = 'All';
  bool _isTechnical = false;
  bool _isNonTechnical = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(
      () => setState(() => _query = _searchController.text.toLowerCase()),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_CompanyData> _getCompanies() {
    final jobs = RecruitmentSyncStore.instance.jobs;
    final Map<String, _CompanyData> map = {};

    for (final job in jobs) {
      final key = job.companyName.toLowerCase();
      final isCurrentCompany =
          job.companyName.toLowerCase() ==
          CompanyStore.instance.companyName.toLowerCase();
      if (map.containsKey(key)) {
        map[key]!.jobs.add(job);
      } else {
        map[key] = _CompanyData(
          name: job.companyName,
          jobs: [job],
          logoUrl: isCurrentCompany
              ? CompanyStore.instance.companyProfileImage
              : job.companyLogoUrl,
          industry: isCurrentCompany
              ? CompanyStore.instance.industry
              : (job.companyIndustry ?? job.classification),
          aboutEn: isCurrentCompany ? CompanyStore.instance.companyAboutEn : '',
          aboutAr: isCurrentCompany ? CompanyStore.instance.companyAboutAr : '',
          website: isCurrentCompany ? CompanyStore.instance.website : '',
          staff: isCurrentCompany ? CompanyStore.instance.staff : '',
          classification: isCurrentCompany
              ? CompanyStore.instance.classification
              : job.classification,
          locations: isCurrentCompany
              ? List.from(CompanyStore.instance.locations)
              : [],
          techStack: isCurrentCompany
              ? List.from(CompanyStore.instance.techStack)
              : [],
          benefits: isCurrentCompany
              ? List.from(CompanyStore.instance.benefits)
              : [],
          foundedYear: isCurrentCompany ? CompanyStore.instance.foundedYear : 0,
        );
      }
    }

    var list = map.values.toList();

    if (_query.isNotEmpty) {
      list = list
          .where(
            (c) =>
                c.name.toLowerCase().contains(_query) ||
                c.industry.toLowerCase().contains(_query),
          )
          .toList();
    }
    if (_selectedLocation != 'All') {
      list = list
          .where((c) => c.jobs.any((j) => j.location == _selectedLocation))
          .toList();
    }
    if (_isTechnical && !_isNonTechnical) {
      list = list.where((c) => c.classification == 'Technical').toList();
    } else if (_isNonTechnical && !_isTechnical) {
      list = list.where((c) => c.classification == 'Non-Technical').toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return AnimatedBuilder(
      animation: RecruitmentSyncStore.instance,
      builder: (context, _) {
        final companies = _getCompanies();

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            leadingWidth: 70,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Center(
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Settings()),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: getAppImageProvider(
                        RecruitmentSyncStore.instance.profileImage,
                      ),
                      child: RecruitmentSyncStore.instance.profileImage == null
                          ? const Icon(
                              Icons.person,
                              size: 20,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ),
            title: Text(
              isAr ? 'تصفح الشركات' : 'Browse Companies',
              style: const TextStyle(
                color: Color(0xFF011931),
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Settings()),
                ),
                icon: const Icon(
                  Icons.settings_outlined,
                  color: Color(0xFF011931),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SizedBox(height: 24),
              Text(
                isAr
                    ? 'ابحث عن شركات أحلامك'
                    : 'Search for companies you dream of',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF011931),
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                isAr
                    ? 'اكتشف أفضل الشركات وبيئات العمل المثالية لمستقبلك المهني'
                    : 'Discover the best companies and ideal work environments for your professional future',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black45,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Search & Filter Bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F1F1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          icon: const Icon(
                            Icons.search,
                            color: Color(0xFF49769F),
                            size: 20,
                          ),
                          hintText: isAr
                              ? 'اسم الشركة أو المجال...'
                              : 'Company or industry...',
                          border: InputBorder.none,
                          hintStyle: const TextStyle(
                            fontSize: 14,
                            color: Colors.black26,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F1F1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedLocation,
                                isExpanded: true,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Color(0xFF49769F),
                                ),
                                items: RecruitmentSyncStore.egyptGovernorates
                                    .map((String gov) {
                                      return DropdownMenuItem<String>(
                                        value: gov,
                                        child: Text(
                                          gov,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      );
                                    })
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null)
                                    setState(() => _selectedLocation = val);
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () => setState(() {}),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF49769F),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              isAr ? 'بحث' : 'Search',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                isAr ? 'التصنيف' : 'Classification',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTypeButton(
                      isAr ? 'تقني' : 'Technical',
                      _isTechnical,
                      () => setState(() => _isTechnical = !_isTechnical),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTypeButton(
                      isAr ? 'غير تقني' : 'Non-Technical',
                      _isNonTechnical,
                      () => setState(() => _isNonTechnical = !_isNonTechnical),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAr ? 'جميع الشركات' : 'All Companies',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          color: Color(0xFF011931),
                        ),
                      ),
                      Text(
                        isAr
                            ? 'إجمالي الشركات المدرجة: ${companies.length}'
                            : 'Total listed companies: ${companies.length}',
                        style: const TextStyle(
                          color: Colors.black38,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.sort_rounded, color: Color(0xFF49769F)),
                ],
              ),
              const SizedBox(height: 20),
              if (companies.isEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.business_outlined,
                        size: 60,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isAr ? 'لا توجد شركات حالياً' : 'No companies found',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isAr
                            ? 'سيتم عرض الشركات بعد نشر الوظائف'
                            : 'Companies will appear once they post jobs',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ...companies.map((c) => _buildCompanyCard(context, c, isAr)),
              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypeButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF49769F) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF49769F)
                : Colors.grey.withOpacity(0.15),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF49769F).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyCard(
    BuildContext context,
    _CompanyData company,
    bool isAr,
  ) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CompanyPublicProfileScreen(
            company: CompanyPublicProfile(
              name: company.name,
              industry: company.industry,
              logoUrl: company.logoUrl,
              aboutEn: company.aboutEn,
              aboutAr: company.aboutAr,
              website: company.website,
              staff: company.staff,
              classification: company.classification,
              locations: company.locations,
              techStack: company.techStack,
              benefits: company.benefits,
              foundedYear: company.foundedYear,
              jobs: List.from(company.jobs),
            ),
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F3FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: company.logoUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image(
                            image: getAppImageProvider(company.logoUrl)!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.business_rounded,
                              color: Color(0xFF49769F),
                              size: 28,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.business_rounded,
                          color: Color(0xFF49769F),
                          size: 28,
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
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                          color: Color(0xFF011931),
                        ),
                      ),
                      if (company.industry.isNotEmpty)
                        Text(
                          company.industry,
                          style: const TextStyle(
                            color: Color(0xFF49769F),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7A2A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isAr
                        ? 'وظائف: ${company.jobs.length}'
                        : '${company.jobs.length} Jobs',
                    style: const TextStyle(
                      color: Color(0xFFFF7A2A),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            if (company.aboutEn.isNotEmpty || company.aboutAr.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                isAr
                    ? (company.aboutAr.isNotEmpty
                          ? company.aboutAr
                          : company.aboutEn)
                    : company.aboutEn,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                  height: 1.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 14),
            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isAr ? 'عرض ملف الشركة' : 'View company profile',
                  style: const TextStyle(
                    color: Color(0xFF49769F),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: Color(0xFF49769F),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CompanyData {
  final String name;
  final List<RecruitmentJob> jobs;
  final String? logoUrl;
  final String industry;
  final String aboutEn;
  final String aboutAr;
  final String website;
  final String staff;
  final String classification;
  final List<String> locations;
  final List<String> techStack;
  final List<String> benefits;
  final int foundedYear;

  _CompanyData({
    required this.name,
    required this.jobs,
    this.logoUrl,
    required this.industry,
    required this.aboutEn,
    required this.aboutAr,
    required this.website,
    required this.staff,
    required this.classification,
    required this.locations,
    required this.techStack,
    required this.benefits,
    required this.foundedYear,
  });
}
