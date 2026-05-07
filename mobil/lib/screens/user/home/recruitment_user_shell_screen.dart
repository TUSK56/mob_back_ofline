import 'package:url_launcher/url_launcher.dart';
import '../../../shared/utils/image_helper.dart';
import 'package:flutter/material.dart';

import '../../../app/router/app_router.dart';
import '../../../shared/l10n/app_localizations.dart';
import '../../../shared/services/recruitment_sync_service.dart';
import '../../../shared/state/recruitment_sync_store.dart';
import '../../../shared/widgets/app_button.dart';
import '../teardsman/setting/settings.dart';
import '../messages/messages_list_screen.dart';
import '../teardsman/nav_Botton_bar/nav_bottom_bar.dart';
import '../profile/user_data.dart';

// Comprehensive Translation Helper
String _translateValue(String? value, bool isAr) {
  if (value == null || value.isEmpty || !isAr) return value ?? "";
  final low = value.trim().toLowerCase();

  // Job Types, Categories & Industries
  if (low == 'full-time' || low == 'full time') return 'دوام كامل';
  if (low == 'part-time' || low == 'part time') return 'دوام جزئي';
  if (low == 'freelance' || low == 'freelancer') return 'عمل حر';
  if (low == 'remote') return 'عن بعد';
  if (low == 'internship') return 'تدريب';
  if (low == 'one-time' || low == 'one time') return 'مرة واحدة';
  if (low == 'service' || low == 'services') return 'خدمة';
  if (low == 'technical') return 'تقني';
  if (low == 'non-technical') return 'غير تقني';
  if (low == 'general') return 'عام';

  // Education Degrees & Levels
  if (low.contains('bachelor')) return 'درجة البكالوريوس';
  if (low.contains('master')) return 'درجة الماجستير';
  if (low.contains('phd') || low.contains('doctorate')) return 'دكتوراه';
  if (low.contains('high school')) return 'الثانوية العامة';
  if (low == 'diploma') return 'دبلوم';
  if (low.contains('university')) return 'جامعة';

  // Job Titles (Common terms found in user input)
  if (low.contains('manager')) return 'مدير';
  if (low.contains('developer')) return 'مطور';
  if (low.contains('engineer')) return 'مهندس';
  if (low.contains('designer')) return 'مصمم';
  if (low.contains('accountant')) return 'محاسب';
  if (low.contains('technician')) return 'فني';
  if (low.contains('teacher')) return 'مدرس';
  if (low.contains('doctor')) return 'طبيب';
  if (low.contains('assistant')) return 'مساعد';
  if (low.contains('specialist')) return 'أخصائي';

  // Status
  if (low.contains('hire')) return 'تم التوظيف';
  if (low.contains('reject') || low.contains('decline')) return 'تم الرفض';
  if (low.contains('pend')) return 'قيد الانتظار';
  if (low.contains('appli')) return 'تم التقديم';
  if (low.contains('interview')) return 'مقابلة';
  if (low.contains('review')) return 'قيد المراجعة';

  return value;
}

class RecruitmentUserShellScreen extends StatefulWidget {
  const RecruitmentUserShellScreen({super.key});

  @override
  State<RecruitmentUserShellScreen> createState() => _RecruitmentUserShellScreenState();
}

class _RecruitmentUserShellScreenState extends State<RecruitmentUserShellScreen> {
  int _tab = 0;
  bool get _isAr => Localizations.localeOf(context).languageCode == 'ar';

  @override
  void initState() {
    super.initState();
    RecruitmentSyncService.instance.startPolling();
  }

  @override
  void dispose() {
    RecruitmentSyncService.instance.stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      const _DiscoverTab(),
      const _ApplicationsTab(),
      const _CompaniesTab(),
      const MessagesListScreen(),
      const _ProfileTab(),
    ];
    final store = RecruitmentSyncStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        // Ensure the Discover tab defaults to showing all jobs.
        if (_tab == 0 &&
            (store.filterLocation != 'All' ||
                store.filterType != 'All' ||
                store.filterCategory != 'All' ||
                store.filterSalaryRange != 'All')) {
          store.updateFilters(
            location: 'All',
            type: 'All',
            classification: 'All',
            salaryRange: 'All',
          );
        }
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            leading: Padding(
              padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const Settings())),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Theme.of(context).cardColor,
                  backgroundImage: getAppImageProvider(store.profileImage),
                  child: store.profileImage == null ? const Icon(Icons.person, size: 20) : null,
                ),
              ),
            ),
            title: Text(
              _tab == 0 
                ? (store.currentUserName.isNotEmpty ? store.currentUserName : (_isAr ? 'اكتشف الوظائف' : 'Discover Jobs'))
                : _tab == 1 ? (_isAr ? 'تقديماتي' : 'My Apps') 
                : _tab == 2 ? (_isAr ? 'الشركات' : 'Browse Companies') 
                : _tab == 3 ? (_isAr ? 'الرسائل' : 'Messages') 
                : (_isAr ? 'الملف الشخصي' : 'Profile'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            centerTitle: false,
            actions: [
              IconButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const Settings())), icon: const Icon(Icons.settings_outlined)),
              const SizedBox(width: 8),
            ],
          ),
          body: pages[_tab],
          floatingActionButton: _tab == 0 
            ? FloatingActionButton(
                onPressed: () {
                  // TODO: Implement chatbot navigation or functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_isAr ? 'قريباً: المساعد الذكي!' : 'Chatbot coming soon!'),
                      backgroundColor: const Color(0xFF4A6ED1),
                    ),
                  );
                },
                backgroundColor: const Color(0xFF4A6ED1),
                shape: const CircleBorder(),
                child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 28),
              )
            : null,
          bottomNavigationBar: NavigationBar(
            backgroundColor: Theme.of(context).cardColor,
            selectedIndex: _tab,
            onDestinationSelected: (int value) => setState(() => _tab = value),
            destinations: <NavigationDestination>[
              NavigationDestination(icon: const Icon(Icons.search), label: _isAr ? 'اكتشف' : 'Discover'),
              NavigationDestination(icon: const Icon(Icons.fact_check), label: _isAr ? 'تقديماتي' : 'My Apps'),
              NavigationDestination(icon: const Icon(Icons.business_center), label: _isAr ? 'الشركات' : 'Companies'),
              NavigationDestination(icon: const Icon(Icons.chat_bubble), label: _isAr ? 'الرسائل' : 'Messages'),
              NavigationDestination(icon: const Icon(Icons.person), label: _isAr ? 'الملف الشخصي' : 'Profile'),
            ],
          ),
        );
      },
    );
  }
}

class _DiscoverTab extends StatelessWidget {
  const _DiscoverTab();

  Widget _buildCompanyLogo(String? logoUrl) {
    final provider = getAppImageProvider(logoUrl);
    return provider == null 
        ? const CircleAvatar(radius: 12, backgroundColor: Color(0xFFF0F3FF), child: Icon(Icons.business, size: 14, color: Color(0xFF49769F)))
        : CircleAvatar(radius: 16, backgroundImage: provider);
  }

  Color _getJobTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'full-time': return Colors.green;
      case 'part-time': return Colors.blue;
      case 'remote': return Colors.purple;
      case 'freelance':
      case 'freelancer': return Colors.teal;
      case 'one-time': return Colors.amber;
      case 'internship': return Colors.indigo;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = RecruitmentSyncStore.instance;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return AnimatedBuilder(
      animation: store,
      builder: (BuildContext context, _) {
        // Home (Discover) should show all posted jobs.
        final jobs = store.jobs;
        return RefreshIndicator(
          onRefresh: () => RecruitmentSyncService.instance.startPolling(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: jobs.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]),
                          child: Row(
                            children: [
                              const Padding(padding: EdgeInsets.only(left: 12), child: Icon(Icons.search, color: Colors.grey, size: 20)),
                              Expanded(flex: 3, child: TextField(decoration: InputDecoration(hintText: isAr ? 'ابحث بالاسم أو الوظيفة...' : 'Search by name or job...', border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 10), hintStyle: const TextStyle(fontSize: 14)), onChanged: (value) => store.updateFilters(searchQuery: value.trim()))),
                              Container(height: 24, width: 1, color: Colors.grey.withValues(alpha: 0.3)),
                              const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.location_on, color: Colors.grey, size: 18)),
                              Expanded(flex: 2, child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: store.filterLocation, isExpanded: true, icon: const Icon(Icons.keyboard_arrow_down, size: 18), style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.w500), items: RecruitmentSyncStore.egyptGovernorates.map((gov) => DropdownMenuItem(value: gov, child: Text(gov, overflow: TextOverflow.ellipsis))).toList(), onChanged: (value) { if (value != null) store.updateFilters(location: value); }))),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]), child: IconButton(onPressed: () => Navigator.of(context).pushNamed(AppRoutes.userAdvancedFilters), icon: Icon(Icons.tune, color: Theme.of(context).iconTheme.color))),
                    ],
                  ),
                );
              }
              final job = jobs[index - 1];
              return Card(
                color: Theme.of(context).cardColor, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.withValues(alpha: 0.1))), margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(children: [_buildCompanyLogo(job.companyLogoUrl)]),
                      const SizedBox(height: 8),
                      Text(job.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8, runSpacing: 8,
                        children: job.type.split(RegExp(r'[•,;]')).map((t) {
                          final type = t.trim();
                          if (type.isEmpty) return const SizedBox.shrink();
                          final color = _getJobTypeColor(type);
                          return Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2))]), child: Text(_translateValue(type, isAr), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)));
                        }).toList(),
                      ),
                      if (job.classification.isNotEmpty && job.classification != 'General' && job.classification != 'All' && job.classification.toLowerCase() != 'services' && job.classification.toLowerCase() != 'service') ...[
                        const SizedBox(height: 8),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFF8B5CF6), borderRadius: BorderRadius.circular(8)), child: Text(_translateValue(job.classification, isAr), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                      ],
                      const SizedBox(height: 8),
                      Wrap(spacing: 8, runSpacing: 8, children: job.tags.where((tag) => tag.trim().toLowerCase() != 'technical').map((String tag) => Chip(label: Text(_translateValue(tag, isAr)), backgroundColor: Theme.of(context).scaffoldBackgroundColor, side: BorderSide.none, padding: const EdgeInsets.symmetric(horizontal: 4))).toList()),
                      if (job.capacity > 0) ...[
                        const SizedBox(height: 12),
                        Text(isAr ? 'مطلوب ${job.capacity} أشخاص' : 'Hiring ${job.capacity} people', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF49769F))),
                        const SizedBox(height: 6),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(isAr ? 'تم القبول: ${job.acceptedCount} / المطلوب: ${job.capacity}' : 'Accepted: ${job.acceptedCount} / Required: ${job.capacity}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: job.acceptedCount >= job.capacity ? Colors.green.shade700 : Colors.blue.shade700)), Text('${((job.acceptedCount / job.capacity) * 100).toInt()}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: job.acceptedCount >= job.capacity ? Colors.green : Colors.blue))]),
                        const SizedBox(height: 6),
                        ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: (job.acceptedCount / job.capacity).clamp(0.0, 1.0), backgroundColor: Colors.grey.withValues(alpha: 0.1), color: job.acceptedCount >= job.capacity ? Colors.green : Theme.of(context).colorScheme.primary, minHeight: 6)),
                      ],
                      const SizedBox(height: 12),
                      Row(children: [Expanded(child: OutlinedButton(style: OutlinedButton.styleFrom(side: BorderSide(color: Theme.of(context).colorScheme.secondary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 8)), onPressed: () => Navigator.of(context).pushNamed(AppRoutes.userJobDetails, arguments: job), child: Text(isAr ? 'عرض التفاصيل' : 'View Details', style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold))))]),
                      const SizedBox(height: 12),
                      AppButton(label: isAr ? 'قدّم الآن' : 'Apply Now', backgroundColor: const Color(0xFF4A6ED1), onPressed: () => Navigator.of(context).pushNamed(AppRoutes.userJobApplication, arguments: job)),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _ApplicationsTab extends StatelessWidget {
  const _ApplicationsTab();
  @override
  Widget build(BuildContext context) {
    final store = RecruitmentSyncStore.instance;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final apps = store.applications;
    final totalApps = apps.length;
    final hiredApps = apps.where((a) => a.status.toLowerCase().contains('hire') || a.status == 'تم التوظيف').length;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) => SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isAr ? '${store.currentUserName} صباح الخير' : 'Good Morning, ${store.currentUserName}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color)),
            const SizedBox(height: 4),
            Text(isAr ? 'هذا ما قمت به بطلباتك حتى الآن' : 'Here is what\'s happening with your applications', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 14)),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: Column(children: [_buildStatCard(context, isAr ? 'إجمالي ما تم التقديم عليه' : 'Total Applied', totalApps.toString(), Icons.description_outlined), const SizedBox(height: 12), _buildStatCard(context, isAr ? 'تم اختيارك في' : 'You were hired in', hiredApps.toString(), Icons.check_circle_outline)])),
                const SizedBox(width: 16),
                Expanded(flex: 3, child: Container(height: 180, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(isAr ? 'حالة التقديم' : 'App Status', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), Expanded(child: Center(child: Stack(alignment: Alignment.center, children: [SizedBox(width: 100, height: 100, child: CircularProgressIndicator(value: totalApps == 0 ? 0 : hiredApps / totalApps, strokeWidth: 10, backgroundColor: Theme.of(context).dividerColor.withValues(alpha: 0.1), valueColor: const AlwaysStoppedAnimation<Color>(Colors.green))), Text('${totalApps > 0 ? (hiredApps / totalApps * 100).toInt() : 0}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))])))]))),
              ],
            ),
            const SizedBox(height: 32),
            Text(isAr ? 'السجل الأخير' : 'Recent Log', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleMedium?.color)),
            const SizedBox(height: 16),
            if (apps.isEmpty) Center(child: Padding(padding: const EdgeInsets.all(40.0), child: Text(isAr ? 'لا يوجد طلبات حالياً' : 'No applications yet.'))) else ...apps.map((app) => _buildRecentAppItem(context, app, isAr)),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon) {
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color)), Icon(icon, color: Theme.of(context).textTheme.bodySmall?.color, size: 20)]), const SizedBox(height: 8), Text(title, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color))]));
  }

  Widget _buildRecentAppItem(BuildContext context, RecruitmentApplication app, bool isAr) {
    final isHired = app.status.toLowerCase().contains('hire');
    return Container(
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.withValues(alpha: 0.1))),
      child: Row(
        children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.business, color: Color(0xFF49769F))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(app.jobTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)), Text('${app.companyName} • ${_translateValue('Full-time', isAr)}', style: const TextStyle(color: Colors.black54, fontSize: 12))])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('${app.updatedAt.day}/${app.updatedAt.month}/${app.updatedAt.year}', style: const TextStyle(fontSize: 11, color: Colors.grey)), const SizedBox(height: 4), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: (isHired ? Colors.green : Colors.orange).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Text(_translateValue(app.status, isAr), style: TextStyle(color: isHired ? Colors.green : Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)))]),
          const SizedBox(width: 8),
          IconButton(onPressed: () => Navigator.of(context).pushNamed(AppRoutes.userApplicationTimeline, arguments: app), icon: const Icon(Icons.more_horiz, color: Colors.grey, size: 20)),
        ],
      ),
    );
  }
}

class _CompaniesTab extends StatefulWidget {
  const _CompaniesTab();
  @override
  State<_CompaniesTab> createState() => _CompaniesTabState();
}

class _CompaniesTabState extends State<_CompaniesTab> {
  bool _technicalChecked = false;
  bool _nonTechnicalChecked = false;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String _searchQuery = "";
  String _locationQuery = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() => _searchQuery = _searchController.text.toLowerCase()));
    _locationController.addListener(() => setState(() => _locationQuery = _locationController.text.toLowerCase()));
  }

  @override
  void dispose() { _searchController.dispose(); _locationController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final store = RecruitmentSyncStore.instance;
    final Map<String, Map<String, dynamic>> companiesMap = {};
    for (final job in store.jobs) {
      final key = job.companyName.trim();
      if (key.isEmpty) continue;
      final openVacancies = (job.capacity - job.acceptedCount).clamp(0, 9999);
      if (!companiesMap.containsKey(key)) {
        companiesMap[key] = {
          'name': job.companyName,
          'industry': _translateValue(job.classification.isEmpty ? 'General' : job.classification, isAr),
          'description': isAr ? 'شركة توظف حالياً عبر Jobito' : 'Hiring now on Jobito',
          'logoUrl': job.companyLogoUrl,
          'vacancies': openVacancies,
          'type': job.classification.toLowerCase().contains('technical') ? 'Technical' : 'Non-Technical',
        };
      } else {
        companiesMap[key]!['vacancies'] = (companiesMap[key]!['vacancies'] as int) + openVacancies;
        if ((companiesMap[key]!['logoUrl'] == null || (companiesMap[key]!['logoUrl'] as String).isEmpty) && (job.companyLogoUrl != null && job.companyLogoUrl!.isNotEmpty)) companiesMap[key]!['logoUrl'] = job.companyLogoUrl;
      }
    }
    final allCompanies = companiesMap.values.toList();
    final filteredCompanies = allCompanies.where((comp) {
      final matchesSearch = comp['name'].toString().toLowerCase().contains(_searchQuery) || comp['industry'].toString().toLowerCase().contains(_searchQuery);
      final matchesLocation = _locationQuery.isEmpty || (isAr ? 'أي مكان' : 'Anywhere').toLowerCase().contains(_locationQuery);
      bool matchesType = true;
      if (_technicalChecked && !_nonTechnicalChecked) matchesType = comp['type'] == 'Technical';
      if (!_technicalChecked && _nonTechnicalChecked) matchesType = comp['type'] == 'Non-Technical';
      return matchesSearch && matchesLocation && matchesType;
    }).toList();
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Column(children: [Text(isAr ? 'ابحث عن الشركات التي تحلم بها' : 'Search for companies you dream of', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Theme.of(context).textTheme.titleLarge?.color), textAlign: TextAlign.center), const SizedBox(height: 10), Text(isAr ? 'اكتشف أفضل الشركات وبيئات العمل المثالية لمستقبلك المهني' : 'Discover the best companies and ideal work environments for your professional future', style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodySmall?.color), textAlign: TextAlign.center)])),
        const SizedBox(height: 30),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Container(height: 55, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]), child: Row(children: [const SizedBox(width: 15), const Icon(Icons.search, color: Color(0xFF49769F), size: 20), Expanded(flex: 3, child: TextField(controller: _searchController, decoration: InputDecoration(hintText: isAr ? 'اسم الشركة أو المجال...' : 'Company or industry...', border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 10), hintStyle: const TextStyle(fontSize: 12, color: Colors.grey)))), Container(width: 1, height: 25, color: Colors.grey.withValues(alpha: 0.2)), const SizedBox(width: 10), const Icon(Icons.location_on_outlined, color: Color(0xFF49769F), size: 20), Expanded(flex: 2, child: TextField(controller: _locationController, decoration: InputDecoration(hintText: isAr ? 'أي مكان' : 'Anywhere', border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 10), hintStyle: const TextStyle(fontSize: 12, color: Colors.grey)))), Padding(padding: const EdgeInsets.all(6.0), child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF49769F), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(horizontal: 16)), child: Text(isAr ? 'بحث' : 'Search', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))))]))),
        const SizedBox(height: 30),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(isAr ? 'التصنيف' : 'Classification', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)), const SizedBox(height: 12), Row(children: [Expanded(child: _buildFilterChip(isAr ? 'تقني' : 'Technical', _technicalChecked, (v) => setState(() => _technicalChecked = v!))), const SizedBox(width: 8), Expanded(child: _buildFilterChip(isAr ? 'غير تقني' : 'Non-Technical', _nonTechnicalChecked, (v) => setState(() => _nonTechnicalChecked = v!)))]), const SizedBox(height: 30)])),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(isAr ? 'جميع الشركات' : 'All Companies', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF011931))), Text(isAr ? 'إجمالي الشركات المدرجة: ${filteredCompanies.length}' : 'Total listed companies: ${filteredCompanies.length}', style: const TextStyle(color: Colors.black38, fontSize: 12)), const SizedBox(height: 20), filteredCompanies.isEmpty ? const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("No results found"))) : GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1, mainAxisExtent: 200, mainAxisSpacing: 16), itemCount: filteredCompanies.length, itemBuilder: (context, index) => _buildCompanyCard(context, filteredCompanies[index], isAr))])),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool value, ValueChanged<bool?> onChanged) => GestureDetector(onTap: () => onChanged(!value), child: Container(padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: value ? const Color(0xFF49769F) : Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: value ? const Color(0xFF49769F) : Colors.grey.shade300)), alignment: Alignment.center, child: Text(label, style: TextStyle(color: value ? Colors.white : Colors.black87, fontSize: 13, fontWeight: FontWeight.w600))));

  Widget _buildCompanyCard(BuildContext context, Map<String, dynamic> comp, bool isAr) {
    final logoProvider = getAppImageProvider(comp['logoUrl']?.toString());
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.withValues(alpha: 0.1)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Material(color: Colors.transparent, child: InkWell(onTap: () {
        Navigator.of(context).pushNamed(AppRoutes.userCompanyDetails, arguments: comp);
      }, borderRadius: BorderRadius.circular(16), child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFF0F3FF), borderRadius: BorderRadius.circular(12)), child: logoProvider != null ? CircleAvatar(radius: 16, backgroundImage: logoProvider) : Icon(Icons.business, color: Theme.of(context).colorScheme.primary, size: 32)), const Spacer(), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2))), child: Text(isAr ? 'وظائف شاغرة ${comp['vacancies']}' : '${comp['vacancies']} Vacancies', style: const TextStyle(color: Color(0xFF49769F), fontSize: 11, fontWeight: FontWeight.bold)))]), const SizedBox(height: 16), Text(comp['name'] as String, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Theme.of(context).colorScheme.onSurface)), const SizedBox(height: 6), Text(comp['description'] as String, style: const TextStyle(color: Colors.black54, fontSize: 13, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis), const Spacer(), Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)), child: Text(comp['industry'] as String, style: const TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.w600))), const Spacer(), Icon(Icons.arrow_forward_ios, size: 14, color: Theme.of(context).colorScheme.primary)])])))),
    );
  }
}

class _ProfileTab extends StatefulWidget {
  const _ProfileTab();
  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final store = RecruitmentSyncStore.instance;

    // Determine status based on role
    final String statusLabel = store.userRole == 'Tradesman' 
        ? t.tr(en: "Tradesman", ar: "صنايعي")
        : t.tr(en: "Job Seeker", ar: "باحث عن عمل");

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final profileImageProvider = getAppImageProvider(store.profileImage);
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(clipBehavior: Clip.none, children: [Container(height: 180, width: double.infinity, decoration: BoxDecoration(gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary.withValues(alpha: 0.9), Theme.of(context).colorScheme.primary.withValues(alpha: 0.6)], begin: Alignment.topLeft, end: Alignment.bottomRight))), Positioned(bottom: -50, left: isAr ? null : 24, right: isAr ? 24 : null, child: Container(decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)]), child: CircleAvatar(radius: 50, backgroundColor: Theme.of(context).cardColor, backgroundImage: profileImageProvider, child: store.profileImage == null ? Icon(Icons.person, size: 55, color: Theme.of(context).colorScheme.primary) : null)))]),
              const SizedBox(height: 60),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (!isAr) ...[
                          _buildEditButton(context, t),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Text(store.currentUserName.isEmpty ? t.notYet : store.currentUserName, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 26, fontWeight: FontWeight.w900)),
                        ),
                        if (isAr) ...[
                          const SizedBox(width: 12),
                          _buildEditButton(context, t),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    // الحالة (باحث عن عمل / صنايعي)
                    Text(statusLabel, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    // العنوان تحت الحالة
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), size: 16),
                        const SizedBox(width: 4),
                        Text(store.currentUserLocation.isEmpty ? t.notYet : store.currentUserLocation, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 30),
                    GestureDetector(onTap: () { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.tr(en: "Switching to Tradesman Mode...", ar: "التبديل إلى وضع الصنايعي...")), backgroundColor: Theme.of(context).colorScheme.secondary, duration: const Duration(seconds: 1))); Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Navbotton())); }, child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16), decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))]), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.swap_horiz, color: Colors.white), const SizedBox(width: 10), Text(t.tr(en: "Switch to Tradesman", ar: "التبديل إلى وضع الصنايعي"), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]))),
                    const SizedBox(height: 30),
                    Container(
                      width: double.infinity, padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))]),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _buildProfileItem(context, t.aboutMe, store.currentUserAbout, Icons.info_outline, showDivider: true),
                        _buildProfileItem(context, isAr ? 'البريد الإلكتروني' : 'Email', store.currentUserEmail, Icons.email_outlined, showDivider: true),
                        _buildProfileItem(context, isAr ? 'رقم الهاتف' : 'Phone', store.currentUserPhone, Icons.phone_android_outlined, showDivider: true),
                        _buildProfileItem(context, isAr ? 'الموقع' : 'Location', store.currentUserLocation, Icons.location_on_outlined, showDivider: true),
                        _buildProfileItem(context, isAr ? 'المهارات' : 'Skills', store.currentUserSkills.join(', '), Icons.psychology_outlined),
                        if (store.portfolioImages.isNotEmpty) ...[const SizedBox(height: 10), Text(isAr ? 'المعرض' : 'Gallery', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Theme.of(context).colorScheme.onSurface)), const SizedBox(height: 16), SizedBox(height: 100, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: store.portfolioImages.length, itemBuilder: (context, index) { final path = store.portfolioImages[index]; return Container(margin: const EdgeInsets.only(right: 12), width: 100, decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)), child: ClipRRect(borderRadius: BorderRadius.circular(14), child: Image(image: getAppImageProvider(path) ?? const AssetImage('assets/placeholder.png'), fit: BoxFit.cover))); }))],
                      ]),
                    ),
                    const SizedBox(height: 24),
                    if (store.currentUserExperience.isNotEmpty) ...[Text(t.workExperience, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.w800)), const SizedBox(height: 16), ...store.currentUserExperience.map((exp) => _buildRecordItem(context, exp['title'], '${exp['company']} • ${exp['duration']}', Icons.work_outline, isAr))],
                    const SizedBox(height: 24),
                    if (store.currentUserEducation.isNotEmpty) ...[Text(t.education, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.w800)), const SizedBox(height: 16), ...store.currentUserEducation.map((edu) => _buildRecordItem(context, edu['degree'], '${edu['institution']} • ${edu['duration']}', Icons.school_outlined, isAr))],
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEditButton(BuildContext context, AppLocalizations t) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.userEditProfile),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF007BFF), // اللون الأزرق
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF007BFF).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.edit, color: Colors.white, size: 14),
            const SizedBox(width: 6),
            Text(
              t.editProfile,
              style: const TextStyle(
                color: Colors.white, 
                fontSize: 12, 
                fontWeight: FontWeight.bold
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordItem(BuildContext context, String? title, String? subtitle, IconData icon, bool isAr) => Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.withValues(alpha: 0.05))), child: Row(children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: Theme.of(context).colorScheme.primary)), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_translateValue(title, isAr), style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color, fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 4), Text(subtitle ?? "", style: const TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w500))]))]));

  Widget _buildProfileItem(BuildContext context, String label, String value, IconData icon, {bool showDivider = false}) {
    final t = AppLocalizations.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38), fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(value.isEmpty ? t.notYet : _translateValue(value, isAr), style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Divider(height: 1, color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
          ),
      ],
    );
  }
}
