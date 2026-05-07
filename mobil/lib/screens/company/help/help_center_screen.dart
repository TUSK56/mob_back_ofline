// Company and User help topics and support entry points.

import 'package:flutter/material.dart';

import '../../../shared/l10n/app_localizations.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/state/recruitment_sync_store.dart';

class CompanyHelpCenterScreen extends StatelessWidget {
  const CompanyHelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final store = RecruitmentSyncStore.instance;
    final isTradesman = store.userRole == 'Tradesman';

    return AppScaffold(
      title: t.tr(en: 'Help Center', ar: 'مركز المساعدة'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: t.tr(en: 'Search help', ar: 'البحث في المساعدة'),
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {},
                child: Text(t.tr(en: 'Relevant', ar: 'ذو صلة')),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SectionTitle(t.tr(en: 'Popular articles', ar: 'المقالات الشائعة')),
          const SizedBox(height: 10),

          // Tradesman specific content
          if (isTradesman) ...[
            _FaqTile(
              title: t.tr(
                en: 'How to add my work to gallery?',
                ar: 'كيف أضيف أعمالي للمعرض؟',
              ),
              body: t.tr(
                en: 'Go to your profile, click on "Edit Profile", and scroll down to the Gallery section to upload your work images.',
                ar: 'انتقل إلى ملفك الشخصي، واضغط على "تعديل الملف الشخصي"، ثم قم بالتمرير لأسفل إلى قسم المعرض لرفع صور أعمالك.',
              ),
            ),
            _FaqTile(
              title: t.tr(
                en: 'How to communicate with customers?',
                ar: 'كيفية التواصل مع العملاء؟',
              ),
              body: t.tr(
                en: 'When a customer contacts you, you will receive a notification and the message will appear in your "Messages" tab.',
                ar: 'عندما يتواصل معك عميل، ستتلقى إشعاراً وستظهر الرسالة في تبويب "الرسائل" الخاص بك.',
              ),
            ),
          ],

          // Common content
          _FaqTile(
            title: t.tr(
              en: 'What is My Applications?',
              ar: 'ما هو قسم "تقديماتي"؟',
            ),
            body: t.tr(
              en: 'My Applications is a way for you to track jobs as you move through the application process...',
              ar: 'قسم تقديماتي هو وسيلة لك لتتبع الوظائف أثناء انتقالك عبر مراحل عملية التقديم المختلفة...',
            ),
          ),
          _FaqTile(
            title: t.tr(
              en: 'How to access my applications history',
              ar: 'كيفية الوصول إلى سجل طلبات التوظيف الخاصة بي',
            ),
            body: t.tr(
              en: 'To access applications history, go to your My Applications page on your dashboard profile...',
              ar: 'للوصول إلى سجل الطلبات، انتقل إلى صفحة تقديماتي في ملفك الشخصي عبر لوحة التحكم الخاصة بك...',
            ),
          ),
          _FaqTile(
            title: t.tr(
              en: 'Not seeing jobs you applied in your my application list?',
              ar: 'لا تظهر الوظائف التي تقدمت إليها في قائمة تقديماتي؟',
            ),
            body: t.tr(
              en: 'Please note that we are unable to track materials submitted for jobs you apply to via an employer’s site...',
              ar: 'يرجى ملاحظة أننا غير قادرين على تتبع المواد المقدمة للوظائف التي تتقدم إليها عبر المواقع الخارجية لأصحاب العمل...',
            ),
          ),
          const SizedBox(height: 18),
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.tr(en: "Didn't find what you were looking for?", ar: 'لم تجد ما كنت تبحث عنه؟'),
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          t.tr(en: 'Contact our customer service', ar: 'اتصل بخدمة العملاء'),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {},
                    child: Text(t.tr(en: 'Contact Us', ar: 'اتصل بنا')),
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

class _FaqTile extends StatefulWidget {
  const _FaqTile({required this.title, required this.body});
  final String title;
  final String body;

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
              if (_expanded) ...[
                const SizedBox(height: 12),
                Text(
                  widget.body,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                        t.tr(en: 'Was this article helpful?', ar: 'هل كان هذا المقال مفيداً؟'),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                    ),
                    const Spacer(),
                    TextButton(onPressed: () {}, child: Text(t.tr(en: 'Yes', ar: 'نعم'), style: const TextStyle(fontSize: 12))),
                    TextButton(onPressed: () {}, child: Text(t.tr(en: 'No', ar: 'لا'), style: const TextStyle(fontSize: 12, color: Colors.red))),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
