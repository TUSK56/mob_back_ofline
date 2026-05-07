// Profile settings hub for the company account.

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../shared/utils/image_helper.dart';

import '../../../shared/l10n/app_localizations.dart';
import '../../../shared/state/company_store.dart';
import '../../../shared/state/locale_controller.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/services/recruitment_sync_service.dart';

import '../../../app/router/app_router.dart';

class CompanyProfileSettingsOverviewScreen extends StatefulWidget {
  const CompanyProfileSettingsOverviewScreen({super.key});

  @override
  State<CompanyProfileSettingsOverviewScreen> createState() =>
      _CompanyProfileSettingsOverviewScreenState();
}

class _CompanyProfileSettingsOverviewScreenState
    extends State<CompanyProfileSettingsOverviewScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final TextEditingController _companyName;
  late final TextEditingController _websiteController;
  late final TextEditingController _staffController;
  late final TextEditingController _industryController;
  late final TextEditingController _about;
  late String _selectedClassification;
  late List<String> _benefits;

  late List<String> _locations;
  late List<String> _techStack;

  late int _selectedDay;
  late int _selectedMonth;
  late int _selectedYear;
  bool _loading = false;
  bool _saveSuccess = false;
  bool _saveError = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final store = CompanyStore.instance;
    final isAr = LocaleController.instance.locale.value.languageCode == 'ar';
    _companyName = TextEditingController(text: store.companyName);
    _websiteController = TextEditingController(text: store.website);
    _staffController = TextEditingController(text: store.staff);
    _industryController = TextEditingController(text: store.industry);
    _about = TextEditingController(text: isAr ? store.companyAboutAr : store.companyAboutEn);
    _benefits = List.from(store.benefits);

    _selectedClassification = store.classification;
    if (_selectedClassification.toLowerCase() == 'technical') {
      _selectedClassification = 'Technical';
    } else if (_selectedClassification.toLowerCase() == 'non-technical' || _selectedClassification.toLowerCase() == 'nontechnical') {
      _selectedClassification = 'Non-Technical';
    } else {
      _selectedClassification = '';
    }
    _locations = List.from(store.locations);
    _techStack = List.from(store.techStack);
    _selectedDay = store.foundedDay;
    _selectedMonth = store.foundedMonth;
    _selectedYear = store.foundedYear;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _companyName.dispose();
    _websiteController.dispose();
    _staffController.dispose();
    _industryController.dispose();
    _about.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final t = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    // Validate
    if (_companyName.text.trim().isEmpty) {
      messenger.showSnackBar(
          SnackBar(content: Text(t.tr(en: 'Company name is required', ar: 'اسم الشركة مطلوب')))
      );
      return;
    }

    setState(() {
      _loading = true;
      _saveSuccess = false;
      _saveError = false;
    });

    try {
      final store = CompanyStore.instance;
      final isAr = LocaleController.instance.locale.value.languageCode == 'ar';

      // Sync with backend first to ensure persistence
      await RecruitmentSyncService.instance.updateProfile(
        name: _companyName.text.trim(),
        about: _about.text.trim(),
        staff: _staffController.text.trim(),
        location: _locations.isNotEmpty ? _locations.first : null,
        website: _websiteController.text.trim(),
        locations: _locations,
        classification: _selectedClassification,
        benefits: _benefits,
        techStack: _techStack,
        industry: _industryController.text.trim(),
        foundedDay: _selectedDay,
        foundedMonth: _selectedMonth,
        foundedYear: _selectedYear,
      );

      // Local persistence
      CompanyStore.instance.updateProfile(
        name: _companyName.text.trim(),
        website: _websiteController.text.trim(),
        staff: _staffController.text.trim(),
        industry: _industryController.text.trim(),
        aboutEn: isAr ? store.companyAboutEn : _about.text.trim(),
        aboutAr: isAr ? _about.text.trim() : store.companyAboutAr,
        locations: _locations,
        techStack: _techStack,
        foundedDay: _selectedDay,
        foundedMonth: _selectedMonth,
        foundedYear: _selectedYear,
        benefits: _benefits,
        classification: _selectedClassification,
        commercialRegister: store.commercialRegister,
        nationalNumber: store.nationalNumber,
      );

      if (!mounted) return;
      setState(() => _saveSuccess = true);
      messenger.showSnackBar(
          SnackBar(
            content: Text(t.saved),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          )
      );
    } catch (e) {
      if (!mounted) return;
      final isUnauthorized = e is DioException && e.response?.statusCode == 401;
      if (isUnauthorized) {
        await RecruitmentSyncService.instance.logout();
      }
      setState(() => _saveError = true);
      final message = isUnauthorized
          ? (t.isAr ? 'انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى.' : 'Session expired. Please sign in again.')
          : (t.isAr ? 'فشل الحفظ: $e' : 'Save failed: $e');
      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (isUnauthorized && mounted) {
        await Future<void>.delayed(const Duration(milliseconds: 250));
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.companySignInNew,
          (route) => false,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return AppScaffold(
      title: t.profileSettings,
      showBack: true,
      body: Column(
        children: [
          const Divider(height: 1, thickness: 1),
          Material(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: TabBar(
              controller: _tabController,
              onTap: (index) async {
                if (index == 1) {
                  await Navigator.of(context).pushNamed(AppRoutes.companyAccountSecurity);
                  if (mounted) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _tabController.index = 0);
                    });
                  }
                } else if (index == 2) {
                  await Navigator.of(context).pushNamed(AppRoutes.companyAppearanceLight);
                  if (mounted) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _tabController.index = 0);
                    });
                  }
                }
              },
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              indicatorColor: Theme.of(context).colorScheme.primary,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
              tabs: [
                Tab(text: t.profileSettings),
                Tab(text: t.accountSecurity),
                Tab(text: t.tr(en: "Appearance", ar: "المظهر")),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildProfileTab(),
                const Center(child: CircularProgressIndicator()),
                const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    final t = AppLocalizations.of(context);
    final months = [
      t.isAr ? 'يناير' : 'January',
      t.isAr ? 'فبراير' : 'February',
      t.isAr ? 'مارس' : 'March',
      t.isAr ? 'أبريل' : 'April',
      t.isAr ? 'مايو' : 'May',
      t.isAr ? 'يونيو' : 'June',
      t.isAr ? 'يوليو' : 'July',
      t.isAr ? 'أغسطس' : 'August',
      t.isAr ? 'سبتمبر' : 'September',
      t.isAr ? 'أكتوبر' : 'October',
      t.isAr ? 'نوفمبر' : 'November',
      t.isAr ? 'ديسمبر' : 'December',
    ];

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildProfileHeader(),
        const SizedBox(height: 30),

        Text(t.tr(en: "Basic Information", ar: "معلومات أساسية"),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(t.tr(en: "Update your company identity and contact details.", ar: "قم بتحديث هوية شركتك وتفاصيل الاتصال."),
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        const Divider(height: 40),

        AppTextField(
          label: t.companyName,
          controller: _companyName,
          validatorText: _saveError && _companyName.text.isEmpty ? 'Required' : null,
        ),
        const SizedBox(height: 20),
        AppTextField(label: t.classification, controller: _staffController),
        const SizedBox(height: 20),

        Text(t.categoryLabel, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        _buildDropdown<String>(
          value: _selectedClassification,
          items: const ['', 'Technical', 'Non-Technical'],
          labelBuilder: (v) {
            if (v.isEmpty) return t.notYet;
            return v == 'Technical' ? t.technical : t.nonTechnical;
          },
          onChanged: (v) => setState(() => _selectedClassification = v!),
        ),
        const SizedBox(height: 20),

        _buildChipField(t.locationInfo, _locations, () => _addTagDialog(t.locationInfo, _locations)),
        const SizedBox(height: 20),

        Text(t.dateFounded, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildDropdown<int>(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                value: _selectedDay,
                items: List.generate(32, (i) => i),
                labelBuilder: (v) => v == 0 ? (t.isAr ? 'اليوم' : 'Day') : v.toString(),
                onChanged: (v) => setState(() => _selectedDay = v!),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: _buildDropdown<int>(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                value: _selectedMonth,
                items: List.generate(13, (i) => i),
                labelBuilder: (v) => v == 0
                    ? (t.isAr ? 'الشهر' : 'Month')
                    : months[v - 1],
                onChanged: (v) => setState(() => _selectedMonth = v!),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: _buildDropdown<int>(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                value: _selectedYear,
                items: [0, ...List.generate(50, (i) => 2024 - i)],
                labelBuilder: (v) => v == 0 ? (t.isAr ? 'السنة' : 'Year') : v.toString(),
                onChanged: (v) => setState(() => _selectedYear = v!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        AppTextField(label: t.website, controller: _websiteController),
        const SizedBox(height: 20),

        AppTextField(label: t.industry, controller: _industryController),
        const SizedBox(height: 20),
 
        AppTextField(label: t.aboutCompany, controller: _about, maxLines: 4),
        const SizedBox(height: 20),
        _buildChipField(t.benefits, _benefits, _addBenefitDialog),
        
        const SizedBox(height: 20),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.link, color: Theme.of(context).colorScheme.primary),
          ),
          title: Text(t.socialLinks, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(t.socialLinksHint, style: const TextStyle(fontSize: 12)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.companyProfileSocialLinks),
        ),

        const SizedBox(height: 40),
        AppButton(
          label: t.saveChange,
          loading: _loading,
          onPressed: _save,
          icon: _saveSuccess ? Icons.check_circle : null,
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: CompanyStore.instance,
            builder: (context, _) {
              final profileImage = CompanyStore.instance.companyProfileImage;
              final imageProvider = getAppImageProvider(profileImage);
              return Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: _saveError ? Colors.red : (_saveSuccess ? Colors.green : Colors.blue.withValues(alpha: 0.2)),
                      width: 3
                  ),
                  image: imageProvider != null ? DecorationImage(image: imageProvider, fit: BoxFit.cover) : null,
                  color: Colors.grey.shade100,
                ),
                child: imageProvider == null ? const Icon(Icons.business, size: 40, color: Colors.grey) : null,
              );
            },
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
              ),
            ),
          ),
          if (_saveError)
            const Positioned.fill(
              child: Center(child: Icon(Icons.error, color: Colors.red, size: 40)),
            ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final t = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
      if (pickedFile != null) {
        setState(() {
          _loading = true;
          _saveError = false;
        });

        final bytes = await pickedFile.readAsBytes();
        final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';

        // Update UI immediately, source of truth remains backend.
        CompanyStore.instance.setRegistrationData(customProfileImage: base64Image);

        // Sync with backend
        await RecruitmentSyncService.instance.updateProfile(photoUrl: base64Image);

        if (mounted) {
          setState(() {
            _saveSuccess = true;
          });
          messenger.showSnackBar(
              SnackBar(content: Text(t.saved), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating)
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final isUnauthorized = e is DioException && e.response?.statusCode == 401;
        if (isUnauthorized) {
          await RecruitmentSyncService.instance.logout();
        }
        setState(() {
          _saveError = true;
          _saveSuccess = false;
        });
        messenger.showSnackBar(
            SnackBar(
                content: Text(isUnauthorized
                    ? t.tr(en: 'Session expired. Please sign in again.', ar: 'انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى.')
                    : t.tr(en: 'Image upload failed', ar: 'فشل تحميل الصورة')),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating
            )
        );
        if (isUnauthorized) {
          await Future<void>.delayed(const Duration(milliseconds: 250));
          if (!mounted) return;
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.companySignInNew,
            (route) => false,
          );
        }
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addTagDialog(String title, List<String> targetList) async {
    final controller = TextEditingController();
    final newTag = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text('Add')),
        ],
      ),
    );
    if (newTag != null && newTag.trim().isNotEmpty) {
      setState(() => targetList.add(newTag.trim()));
    }
  }

  Future<void> _addBenefitDialog() async {
    final t = AppLocalizations.of(context);
    final titleController = TextEditingController();
    final descController = TextEditingController();
    
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.benefits),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: t.tr(en: 'Title', ar: 'العنوان'),
                hintText: t.tr(en: 'e.g. Health Insurance', ar: 'مثلاً: تأمين طبي'),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: t.tr(en: 'Description', ar: 'الوصف'),
                hintText: t.tr(en: 'Provide more details...', ar: 'أضف المزيد من التفاصيل...'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.tr(en: 'Cancel', ar: 'إلغاء'))),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, {
              'title': titleController.text,
              'description': descController.text,
            }),
            child: Text(t.tr(en: 'Add', ar: 'إضافة')),
          ),
        ],
      ),
    );

    if (result != null && result['title']!.trim().isNotEmpty) {
      final formatted = result['description']!.trim().isEmpty 
          ? result['title']!.trim() 
          : "${result['title']!.trim()}:::${result['description']!.trim()}";
      setState(() => _benefits.add(formatted));
    }
  }

  Widget _buildChipField(String label, List<String> items, VoidCallback onAdd) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Wrap(
            spacing: 8,
            children: [
              ...items.map((item) => Chip(
                label: Text(item.split(':::')[0]),
                onDeleted: () => setState(() => items.remove(item)),
              )),
              ActionChip(label: const Text('+ Add'), onPressed: onAdd),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required String Function(T) labelBuilder,
    required ValueChanged<T?> onChanged,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      labelBuilder(e),
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
