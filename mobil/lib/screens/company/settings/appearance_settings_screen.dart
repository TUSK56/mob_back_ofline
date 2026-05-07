// Theme and language appearance settings.

import 'package:flutter/material.dart';

import '../../../shared/l10n/app_localizations.dart';
import '../../../shared/state/locale_controller.dart';
import '../../../shared/state/theme_controller.dart';
import '../../../shared/widgets/app_scaffold.dart';

class CompanyAppearanceSettingsScreen extends StatefulWidget {
  const CompanyAppearanceSettingsScreen({
    super.key,
    required this.initialTheme,
  });

  final String initialTheme;

  @override
  State<CompanyAppearanceSettingsScreen> createState() =>
      _CompanyAppearanceSettingsScreenState();
}

class _CompanyAppearanceSettingsScreenState
    extends State<CompanyAppearanceSettingsScreen> with SingleTickerProviderStateMixin {
  late String _theme = widget.initialTheme;
  late String _lang;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 2);
    _theme = ThemeController.instance.themeMode.value == ThemeMode.light
        ? 'Light'
        : 'Dark';
    _lang = LocaleController.instance.locale.value.languageCode == 'ar'
        ? 'العربية'
        : 'English';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
              onTap: (index) {
                if (index == 0) {
                  Navigator.pop(context);
                } else if (index == 1) {
                  Navigator.pushReplacementNamed(context, '/company/settings/account_security');
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.tr(en: 'Theme', ar: 'المظهر العام'),
                      style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 10),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Dark', label: Text('Dark')),
                ButtonSegment(value: 'Light', label: Text('Light')),
              ],
              selected: {_theme},
              onSelectionChanged: (s) {
                final selected = s.first;
                setState(() => _theme = selected);
                if (selected == 'Light') {
                  ThemeController.instance.setLight();
                } else {
                  ThemeController.instance.setDark();
                }
              },
            ),
            const SizedBox(height: 20),
            Text(t.tr(en: 'Language', ar: 'اللغة'),
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 10),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'English', label: Text('English')),
                ButtonSegment(value: 'العربية', label: Text('العربية')),
              ],
              selected: {_lang},
              onSelectionChanged: (s) {
                final selected = s.first;
                setState(() => _lang = selected);
                if (selected == 'العربية') {
                  LocaleController.instance.locale.value = const Locale('ar');
                } else {
                  LocaleController.instance.locale.value = const Locale('en');
                }
              },
            ),
            const Spacer(),
            Text(
              t.tr(
                en: 'Default theme is Dark. Light applies only when selected here.',
                ar: 'المظهر الافتراضي هو الداكن. المظهر الفاتح يتم تطبيقه فقط عند اختياره من هنا.',
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    ),
  ],
),
);
  }
}
