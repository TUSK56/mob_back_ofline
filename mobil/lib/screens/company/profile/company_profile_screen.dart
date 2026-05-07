// Public-style company profile with tabs and store data.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/l10n/app_localizations.dart';
import '../../../shared/state/company_store.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/section_title.dart';
import '../widgets/company_app_bar_actions.dart';
import '../widgets/company_bottom_nav.dart';

class CompanyCompanyProfileScreen extends StatefulWidget {
  const CompanyCompanyProfileScreen({super.key});

  @override
  State<CompanyCompanyProfileScreen> createState() =>
      _CompanyCompanyProfileScreenState();
}

class _CompanyCompanyProfileScreenState
    extends State<CompanyCompanyProfileScreen> {
  final _store = CompanyStore.instance;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return AppScaffold(
      title: t.profile,
      showBack: false,
      leading: const CompanyProfileLeading(),
      actions: const [CompanyAppBarActions()],
      showAppBarDivider: true,
      body: AnimatedBuilder(
        animation: _store,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _CompanyStatsBar(
                foundedDay: _store.foundedDay,
                foundedMonth: _store.foundedMonth,
                foundedYear: _store.foundedYear,
                countriesCount: _store.locations.length,
                staff: _store.staff,
                industry: _store.industry,
              ),
              const SizedBox(height: 14),
              Divider(
                height: 1,
                thickness: 1,
                color: Theme.of(context).dividerColor.withOpacity(0.2),
              ),
              const SizedBox(height: 16),
              SectionTitle(t.about),
              const SizedBox(height: 10),
              Text(
                t.isAr
                    ? (_store.companyAboutAr.trim().isNotEmpty
                    ? _store.companyAboutAr
                    : (_store.companyAboutEn.trim().isNotEmpty ? _store.companyAboutEn : t.notYet))
                    : (_store.companyAboutEn.trim().isNotEmpty ? _store.companyAboutEn : t.notYet),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: (_store.companyAboutAr.isEmpty && _store.companyAboutEn.isEmpty)
                      ? Theme.of(context).colorScheme.onSurface.withOpacity(0.4)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              SectionTitle(t.benefits),
              const SizedBox(height: 10),
              _store.benefits.isEmpty
                  ? Text(t.notYet, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)))
                  : Column(
                children: _store.benefits.map((item) {
                  final parts = item.split(':::');
                  final title = parts[0];
                  final desc = parts.length > 1 ? parts[1] : '';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle_outline, size: 20, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              if (desc.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  desc,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              if (_store.commercialRegister.isNotEmpty || _store.nationalNumber.isNotEmpty) ...[
                SectionTitle(t.tr(en: 'Registration Info', ar: 'بيانات التسجيل')),
                const SizedBox(height: 10),
                if (_store.commercialRegister.isNotEmpty)
                  _RegistrationInfoTile(
                    icon: Icons.assignment_outlined,
                    title: t.tr(en: 'Commercial Register', ar: 'السجل التجاري'),
                    value: _store.commercialRegister,
                  ),
                if (_store.nationalNumber.isNotEmpty)
                  _RegistrationInfoTile(
                    icon: Icons.badge_outlined,
                    title: t.tr(en: 'National Number', ar: 'الرقم القومي'),
                    value: _store.nationalNumber,
                  ),
                const SizedBox(height: 16),
              ],
              if (_store.contacts.isNotEmpty) ...[
                SectionTitle(t.contactSectionLabel),
                const SizedBox(height: 10),
                ..._store.contacts.asMap().entries.map(
                      (entry) => _EditableLinkTile(
                    icon: entry.value.name.toLowerCase().contains('email')
                        ? Icons.email_outlined
                        : Icons.link_outlined,
                    title: entry.value.name,
                    value: entry.value.value,
                  ),
                ),
              ],
            ],
          );
        },
      ),
      bottomNavigationBar: const CompanyBottomNav(
        current: CompanyTab.profile,
      ),
    );
  }
}

class _EditableLinkTile extends StatelessWidget {
  const _EditableLinkTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  Future<void> _copy(BuildContext context) async {
    final t = AppLocalizations.of(context);
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.isAr ? 'تم نسخ الرابط' : 'Copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(value),
        onTap: () => _copy(context),
      ),
    );
  }
}

class _RegistrationInfoTile extends StatelessWidget {
  const _RegistrationInfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(value),
        onTap: () async {
          final t = AppLocalizations.of(context);
          await Clipboard.setData(ClipboardData(text: value));
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.isAr ? 'تم النسخ' : 'Copied to clipboard')),
          );
        },
      ),
    );
  }
}

class _CompanyStatsBar extends StatelessWidget {
  const _CompanyStatsBar({
    required this.foundedDay,
    required this.foundedMonth,
    required this.foundedYear,
    required this.countriesCount,
    required this.staff,
    required this.industry,
  });

  final int foundedDay;
  final int foundedMonth;
  final int foundedYear;
  final int countriesCount;
  final String staff;
  final String industry;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final labelColor = Theme.of(
      context,
    ).colorScheme.onSurface.withOpacity(0.65);
    final iconColor = Theme.of(
      context,
    ).colorScheme.onSurface.withOpacity(0.9);

    Widget item({
      required IconData icon,
      required String label,
      required String value,
    }) {
      return Expanded(
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: labelColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                item(
                  icon: Icons.local_fire_department_outlined,
                  label: t.tr(en: 'Founded', ar: 'تاريخ التأسيس'),
                  value: (foundedDay == 0 || foundedMonth == 0 || foundedYear == 0)
                      ? t.notYet
                      : t.tr(
                      en: '$foundedMonth/$foundedDay/$foundedYear',
                      ar: '$foundedYear/$foundedMonth/$foundedDay'.replaceAll('0', '٠').replaceAll('1', '١').replaceAll('2', '٢').replaceAll('3', '٣').replaceAll('4', '٤').replaceAll('5', '٥').replaceAll('6', '٦').replaceAll('7', '٧').replaceAll('8', '٨').replaceAll('9', '٩')
                  ),
                ),
                const SizedBox(width: 14),
                item(
                  icon: Icons.location_on_outlined,
                  label: t.locationInfo,
                  value: countriesCount == 0 ? t.notYet : countriesCount.toString(),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                item(
                  icon: Icons.groups_outlined,
                  label: t.classification,
                  value: staff.isEmpty ? t.notYet : staff,
                ),
                const SizedBox(width: 14),
                item(
                  icon: Icons.category_outlined,
                  label: t.categoryLabel,
                  value: industry.isEmpty ? t.notYet : industry,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}