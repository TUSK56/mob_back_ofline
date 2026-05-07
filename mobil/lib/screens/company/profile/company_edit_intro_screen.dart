// Bilingual company “about” editor with polish/export helpers.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/l10n/app_localizations.dart';
import '../../../shared/services/intro_json_export.dart';
import '../../../shared/services/intro_polish_service.dart';
import '../../../shared/state/company_store.dart';
import '../../../shared/widgets/app_scaffold.dart';

class CompanyEditIntroArgs {
  const CompanyEditIntroArgs({
    required this.english,
    required this.arabic,
  });

  final String english;
  final String arabic;
}

/// LinkedIn-style “Edit intro”: Arabic (left tab) + English primary (right tab).
class CompanyEditIntroScreen extends StatefulWidget {
  const CompanyEditIntroScreen({
    super.key,
    required this.initialEnglish,
    required this.initialArabic,
  });

  final String initialEnglish;
  final String initialArabic;

  @override
  State<CompanyEditIntroScreen> createState() => _CompanyEditIntroScreenState();
}

class _CompanyEditIntroScreenState extends State<CompanyEditIntroScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final TextEditingController _en;
  late final TextEditingController _ar;
  bool _polishing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
    _en = TextEditingController(text: widget.initialEnglish);
    _ar = TextEditingController(text: widget.initialArabic);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _en.dispose();
    _ar.dispose();
    super.dispose();
  }

  Future<void> _runPolish() async {
    FocusScope.of(context).unfocus();
    setState(() => _polishing = true);
    try {
      final result = await IntroPolishService.polish(_en.text);
      if (!mounted) return;
      setState(() {
        _en.text = result.english;
        _ar.text = result.arabic;
      });
    } finally {
      if (mounted) setState(() => _polishing = false);
    }
  }

  Future<void> _save() async {
    final t = AppLocalizations.of(context);
    final en = _en.text.trim();
    final ar = _ar.text.trim();
    try {
      final dir = await IntroJsonExport.saveBoth(
        englishAbout: en,
        arabicAbout: ar,
      );
      CompanyStore.instance.setCompanyIntro(english: en, arabic: ar);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.tr(en: 'Saved. JSON files: $dir', ar: 'تم الحفظ. ملفات JSON: $dir')),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.tr(en: 'Failed to save: $e', ar: 'تعذّر الحفظ: $e'))),
      );
    }
  }

  Future<void> _copyJson(bool english) async {
    final t = AppLocalizations.of(context);
    final r = IntroPolishResult(english: _en.text.trim(), arabic: _ar.text.trim());
    final text = english ? r.toEnglishJson() : r.toArabicJson();
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(english ? t.tr(en: 'English JSON copied', ar: 'تم نسخ English JSON') : t.tr(en: 'Arabic JSON copied', ar: 'تم نسخ Arabic JSON')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return AppScaffold(
      title: t.tr(en: 'Edit intro', ar: 'تعديل التعريف'),
      showBack: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Theme.of(context).colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'العربية'),
                Tab(text: 'English (Primary profile)'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _ar,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      alignLabelWithHint: true,
                      labelText: t.tr(en: 'About / Intro (Arabic)', ar: 'نبذة عني / التعريف'),
                      hintText: t.tr(en: 'Write your Arabic intro...', ar: 'اكتب النسخة العربية لملفك التعريفي…'),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _en,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      alignLabelWithHint: true,
                      labelText: t.tr(en: 'About / Intro (primary)', ar: 'نبذة عني (لغة رئيسية)'),
                      hintText: t.tr(en: 'Write your English intro — primary profile language…', ar: 'اكتب النسخة الانجليزية لملفك التعريفي...'),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  t.tr(
                    en: 'Polishes the English text and suggests a professional Arabic version (offline). You can manually edit any tab before saving.',
                    ar: 'يُحسّن النص الإنجليزي ثم يقترح نسخة عربية مهنية (بدون إنترنت). يمكنك تعديل أي تبويب يدويًا قبل الحفظ.'
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.75),
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _polishing ? null : _runPolish,
                        icon: _polishing
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              )
                            : const Icon(Icons.auto_fix_high_outlined),
                        label: Text(_polishing ? t.tr(en: 'Polishing...', ar: 'جاري التحسين…') : t.tr(en: 'Polish', ar: 'تحسين')),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      tooltip: t.tr(en: 'Copy English JSON', ar: 'نسخ الإصدار الإنجليزي JSON'),
                      onPressed: () => _copyJson(true),
                      icon: const Icon(Icons.copy_outlined),
                    ),
                    IconButton(
                      tooltip: t.tr(en: 'Copy Arabic JSON', ar: 'نسخ الإصدار العربي JSON'),
                      onPressed: () => _copyJson(false),
                      icon: const Icon(Icons.copy_all_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: _save,
                  child: Text(t.save),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
