// Inbox of recruiter message threads.

import 'package:flutter/material.dart';

import '../../../app/router/app_router.dart';
import '../../../constants/app_images.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/l10n/app_localizations.dart';
import '../../../shared/models/message_thread.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../widgets/company_app_bar_actions.dart';
import '../widgets/company_bottom_nav.dart';

class CompanyMessagesListScreen extends StatelessWidget {
  const CompanyMessagesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final threads = MockData.threads();
    final t = AppLocalizations.of(context);
    return AppScaffold(
      title: t.tr(en: 'Messages', ar: 'الرسائل'),
      showBack: false,
      leading: const CompanyProfileLeading(),
      actions: const [CompanyAppBarActions()],
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (_, i) => _ThreadTile(thread: threads[i], avatarIndex: i),
        separatorBuilder: (_, i) =>
            Divider(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5), height: 1),
        itemCount: threads.length,
      ),
      bottomNavigationBar: const CompanyBottomNav(current: CompanyTab.chat),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.companyNewChat),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ThreadTile extends StatelessWidget {
  const _ThreadTile({required this.thread, required this.avatarIndex});

  final MessageThread thread;
  final int avatarIndex;

  static const _avatars = [
    AppImages.companyProfile1,
    AppImages.companyProfile2,
    AppImages.companyProfile3,
    AppImages.companyProfile4,
    AppImages.companyProfile5,
    AppImages.companyProfile6,
    AppImages.companyProfile7,
  ];

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final path = _avatars[avatarIndex % _avatars.length];
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        backgroundImage: AssetImage(path),
      ),
      title: Text(thread.title),
      subtitle: Text(
        thread.subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        t.isAr ? thread.lastTimeLabelAr : thread.lastTimeLabelEn,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
      ),
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.companyChatThread, arguments: thread),
    );
  }
}

