import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import '../../../constants/app_images.dart';
import '../../../shared/services/recruitment_sync_service.dart';
import '../../../shared/state/recruitment_sync_store.dart';
import '../../../shared/utils/image_helper.dart';
import '../notifications/notifications_screen.dart';
import '../settings/setting_screen.dart';
import '../../../shared/l10n/app_localizations.dart';

class TechnicalScreen extends StatefulWidget {
  const TechnicalScreen({super.key});

  @override
  State<TechnicalScreen> createState() => _TechnicalScreenState();
}

class _TechnicalScreenState extends State<TechnicalScreen> {
  bool _isEmploymentExpanded = false;
  bool _isSalaryExpanded = false;

  String _selectedClassification = "technical";
  String _selectedLocation = "Cairo";
  final TextEditingController _searchController = TextEditingController();

  final List<String> _egyptGovernorates = [
    "Cairo", "Giza", "Alexandria", "Dakahlia", "Red Sea", "Beheira", "Fayoum", 
    "Gharbia", "Ismailia", "Monufia", "Minya", "Qalyubia", "New Valley", 
    "Sharqia", "Suez", "Aswan", "Assiut", "Beni Suef", "Port Said", 
    "Damietta", "South Sinai", "Kafr El Sheikh", "Matrouh", "Luxor", "Qena", "Sohag", "North Sinai"
  ];


  final Map<String, bool> _selectedFilters = {
    "Full-time (3)": true, "Part-Time (5)": false, "Remote (2)": false,
    "Internship (24)": false, "Contract (3)": false, "Design (24)": true,
    "Sales (3)": false, "Marketing (3)": true, "Business (3)": false,
    "Human Resource (6)": false, "Entry Level (57)": false, "Mid Level (3)": false,
    "Senior Level (5)": true, "Director (12)": false, "VP or Above (8)": false,
    "\$700 - \$1000 (4)": false, "\$1000 - \$1500 (8)": false,
    "\$1500 - \$2000 (10)": false, "\$3000 or above (4)": false,
  };

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    RecruitmentSyncService.instance.startPolling();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showProfileImage(BuildContext context, ImageProvider? provider) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            if (provider != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image(image: provider, fit: BoxFit.contain),
              )
            else
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.person, size: 120, color: Colors.grey),
              ),
            Positioned(
              right: 8,
              top: 8,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const CircleAvatar(
                  backgroundColor: Colors.black54,
                  radius: 15,
                  child: Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final store = RecruitmentSyncStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(store),
              const SizedBox(height: 25),
              _buildSearchSection(),
              const SizedBox(height: 15),
              Text("${t.tr(en: "Popular", ar: "شائع")} : UI Designer, UX Researcher, Android", 
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38), fontSize: 11)),
              const SizedBox(height: 25),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildFilterSection(
                      title: "Type of Employment",
                      isExpanded: _isEmploymentExpanded,
                      onToggle: () => setState(() => _isEmploymentExpanded = !_isEmploymentExpanded),
                      items: ["Full-time (3)", "Part-Time (5)", "Remote (2)", "Internship (24)", "Contract (3)"],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildFilterSection(
                      title: "Salary Range",
                      isExpanded: _isSalaryExpanded,
                      onToggle: () => setState(() => _isSalaryExpanded = !_isSalaryExpanded),
                      items: ["\$700 - \$1000 (4)", "\$1000 - \$1500 (8)", "\$1500 - \$2000 (10)", "\$3000 or above (4)"],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
              Divider(color: Theme.of(context).dividerColor.withValues(alpha: 0.12), height: 1),
              const SizedBox(height: 25),
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(text: t.tr(en: "Explore By ", ar: "استكشف حسب "), style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                    TextSpan(text: t.categoryLabel, style: const TextStyle(color: Color(0xFF578BC7))),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildCategoryTabs(),
              const SizedBox(height: 25),
              _buildDynamicJobSection(t),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
        );
      },
    );
  }

  Widget _buildTopBar(RecruitmentSyncStore store) {
    final profileImageProvider = getAppImageProvider(store.profileImage);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => _showProfileImage(context, profileImageProvider),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(context).cardColor,
            backgroundImage: profileImageProvider,
            child: store.profileImage == null ? const Icon(Icons.person, size: 22) : null,
          ),
        ),
        Row(
          children: [
            _buildTopIconButton(Icons.notifications_none, 
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()))),
            const SizedBox(width: 12),
            _buildTopIconButton(Icons.settings_outlined, 
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingScreen()))),
          ],
        ),
      ],
    );
  }

  Widget _buildTopIconButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark 
              ? const Color(0xFF0D2D4D) 
              : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1), 
          shape: BoxShape.circle, 
          border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.12))
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.onSurface, size: 22),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1))
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38), size: 18),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() {}),
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 13), 
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).tr(en: "Search jobs", ar: "البحث عن وظائف"), 
                hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38)), 
                border: InputBorder.none
              )
            )
          ),
          Container(height: 20, width: 1, color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _showLocationPicker,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Icon(Icons.location_on_outlined, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38), size: 18),
                const SizedBox(width: 4),
                Text(_selectedLocation, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12)),
                Icon(Icons.keyboard_arrow_down, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38), size: 18),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), 
            decoration: BoxDecoration(color: const Color(0xFF4A6ED1), borderRadius: BorderRadius.circular(20)), 
            child: Text(AppLocalizations.of(context).tr(en: "Search", ar: "بحث"), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))
          ),
        ],
      ),
    );
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          children: [
            const SizedBox(height: 10),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Theme.of(context).dividerColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text("Select Governorate", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _egyptGovernorates.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_egyptGovernorates[index], style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                    onTap: () {
                      setState(() => _selectedLocation = _egyptGovernorates[index]);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryTabs() {
    final t = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(child: _buildTabItem(t.tr(en: "Technical", ar: "تقني"), "technical", Bootstrap.laptop, const Color(0xFF6C63FF))),
        const SizedBox(width: 10),
        Expanded(child: _buildTabItem(t.tr(en: "Non-Technical", ar: "إداري"), "non-technical", FontAwesome.user_tie_solid, const Color(0xFF4CAF50))),
        const SizedBox(width: 10),
        Expanded(child: _buildTabItem(t.tr(en: "Services", ar: "خدمات"), "service", Bootstrap.bell, const Color(0xFFFF9800))),
      ],
    );
  }

  Widget _buildTabItem(String label, String value, IconData icon, Color activeColor) {
    bool isSelected = _selectedClassification == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedClassification = value),
      child: AnimatedScale(
        scale: isSelected ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutQuart,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).cardColor : Colors.black.withValues(alpha: 0.05)),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: isSelected ? Colors.white.withValues(alpha: 0.6) : Theme.of(context).dividerColor.withValues(alpha: 0.1)),
            boxShadow: isSelected ? [
              BoxShadow(
                color: activeColor.withValues(alpha: 0.4),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              )
            ] : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                size: 28,
              ),
              const SizedBox(height: 15),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection({required String title, required bool isExpanded, required VoidCallback onToggle, required List<String> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onToggle,
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis)),
              Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Theme.of(context).colorScheme.onSurface, size: 18),
            ],
          ),
        ),
        if (isExpanded)
          Column(
            children: [
              const SizedBox(height: 10),
              ...items.map((item) => _buildCheckbox(item)),
            ],
          ),
      ],
    );
  }

  Widget _buildCheckbox(String label) {
    bool isSelected = _selectedFilters[label] ?? false;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilters[label] = !isSelected),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: [
            Container(
              width: 16, height: 16,
              decoration: BoxDecoration(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent, borderRadius: BorderRadius.circular(4), border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38))),
              child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 12) : null,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 11), overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicJobSection(AppLocalizations t) {
    final store = RecruitmentSyncStore.instance;
    final String query = _searchController.text.toLowerCase();
    
    final List<RecruitmentJob> classificationJobs = store.jobs
        .where((job) => job.classification.toLowerCase() == _selectedClassification.toLowerCase() && 
                job.title.toLowerCase().contains(query))
        .toList();

    if (classificationJobs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text(t.tr(en: "No jobs found matching your search", ar: "لم يتم العثور على وظائف تطابق بحثك"), style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), fontSize: 14)),
        ),
      );
    }

    return Column(
      children: [
        _buildSectionHeader("All jobs"),
        const SizedBox(height: 15),
        ...classificationJobs.map((job) => _buildJobCard(
          title: job.title,
          company: job.companyName,
          location: job.location,
          applied: job.acceptedCount,
          capacity: job.capacity,
        )),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    final t = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
            children: [
              TextSpan(text: title.split(' ')[0]),
              const TextSpan(text: " "),
              TextSpan(text: title.split(' ')[1], style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            ],
          ),
        ),
        Row(
          children: [
            Text(t.tr(en: "Show all jobs", ar: "عرض الكل"), style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), fontSize: 12)),
            const SizedBox(width: 4),
            Icon(Icons.arrow_forward, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), size: 16),
          ],
        ),
      ],
    );
  }

  Widget _buildJobCard({required String title, required String company, required String location, required int applied, required int capacity}) {
    final t = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: const DecorationImage(
                image: AssetImage(AppImages.companyProfile1),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 15)),
                Text("$company • $location", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38), fontSize: 12)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildTag("Full-Time"),
                    // Removed Technical tag if it existed as dark badge
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(color: const Color(0xFF4A6ED1), borderRadius: BorderRadius.circular(20)),
                child: Text(t.tr(en: "Apply", ar: "تقديم"), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              const SizedBox(height: 10),
              Text("$applied ${t.tr(en: 'applied', ar: 'متقدم')}", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38), fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, {bool isHighlighted = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isHighlighted ? Theme.of(context).cardColor : Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isHighlighted ? Colors.orange.withValues(alpha: 0.5) : Theme.of(context).dividerColor.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(color: isHighlighted ? Colors.orange : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 10),
      ),
    );
  }
}
