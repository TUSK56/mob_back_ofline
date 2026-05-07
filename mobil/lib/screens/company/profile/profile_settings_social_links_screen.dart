// Edit social and external links on the company profile.

import 'package:flutter/material.dart';

import '../../../shared/models/contact_entry.dart';
import '../../../shared/l10n/app_localizations.dart';
import '../../../shared/state/company_store.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_scaffold.dart';

class CompanyProfileSettingsSocialLinksScreen extends StatefulWidget {
  const CompanyProfileSettingsSocialLinksScreen({super.key});

  @override
  State<CompanyProfileSettingsSocialLinksScreen> createState() =>
      _CompanyProfileSettingsSocialLinksScreenState();
}

class _CompanyProfileSettingsSocialLinksScreenState
    extends State<CompanyProfileSettingsSocialLinksScreen> {
  bool _loading = false;

  Future<void> _save() async {
    final t = AppLocalizations.of(context);
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(t.saved)));
  }

  Future<void> _addMore() async {
    final t = AppLocalizations.of(context);
    final name = TextEditingController();
    final value = TextEditingController();
    final created = await _showContactDialog(
      title: t.addSocialLink,
      nameController: name,
      valueController: value,
    );
    if (created == null) return;
    CompanyStore.instance.addContact(created);
  }

  Future<void> _edit(int index, ContactEntry entry) async {
    final t = AppLocalizations.of(context);
    final name = TextEditingController(text: entry.name);
    final value = TextEditingController(text: entry.value);
    final updated = await _showContactDialog(
      title: t.editSocialLink,
      nameController: name,
      valueController: value,
    );
    if (updated == null) return;
    CompanyStore.instance.updateContact(index, updated);
  }

  Future<ContactEntry?> _showContactDialog({
    required String title,
    required TextEditingController nameController,
    required TextEditingController valueController,
  }) {
    final t = AppLocalizations.of(context);
    return showDialog<ContactEntry>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: t.nameLabel),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: valueController,
              decoration: InputDecoration(labelText: t.urlHandle),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(
              ContactEntry(
                name: nameController.text.trim(),
                value: valueController.text.trim(),
              ),
            ),
            child: Text(t.save),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return AppScaffold(
      title: t.profileSettings,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            t.socialLinks,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          Text(
            t.socialLinksHint,
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: CompanyStore.instance,
            builder: (context, _) => Column(
              children: [
                ...CompanyStore.instance.contacts.asMap().entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: ListTile(
                        title: Text(entry.value.name),
                        subtitle: Text(entry.value.value),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => _edit(entry.key, entry.value),
                              icon: const Icon(Icons.edit_outlined),
                            ),
                            IconButton(
                              onPressed: () => CompanyStore.instance
                                  .removeContact(entry.key),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: t.isAr ? Alignment.centerRight : Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: _addMore,
                    icon: const Icon(Icons.add),
                    label: Text(t.addMore),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          AppButton(label: t.saveChange, loading: _loading, onPressed: _save),
        ],
      ),
    );
  }
}
