import 'package:flutter/material.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/state/recruitment_sync_store.dart';
import '../../../shared/models/applicant.dart';
import '../../../shared/models/message_thread.dart';
import '../../../app/router/app_router.dart';
import '../widgets/company_applicant_avatar.dart';
import '../../../shared/l10n/app_localizations.dart';

class CompanyNewChatScreen extends StatefulWidget {
  const CompanyNewChatScreen({super.key});

  @override
  State<CompanyNewChatScreen> createState() => _CompanyNewChatScreenState();
}

class _CompanyNewChatScreenState extends State<CompanyNewChatScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    
    return ListenableBuilder(
      listenable: RecruitmentSyncStore.instance,
      builder: (context, _) {
        final allApplicants = RecruitmentSyncStore.instance.applications.map((app) => Applicant(
          id: app.id,
          fullName: app.userName,
          role: app.jobTitle,
          rating: 4.5,
          stage: app.status,
          email: app.email ?? '',
          phone: app.phone ?? '',
          location: app.location ?? '',
          appliedDateLabel: 'Today',
          jobId: app.jobId,
        )).toList();

        final filtered = allApplicants.where((a) {
          if (_query.isEmpty) return true;
          final q = _query.toLowerCase();
          return a.fullName.toLowerCase().contains(q) || a.email.toLowerCase().contains(q);
        }).toList();

        return AppScaffold(
          title: t.newChat,
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: t.searchUsersHint,
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final applicant = filtered[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
                      ),
                      child: ListTile(
                        leading: CompanyApplicantAvatar(seed: applicant.id, radius: 20),
                        title: Text(applicant.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(applicant.email, style: const TextStyle(fontSize: 12)),
                        onTap: () {
                          final thread = MessageThread(
                            id: 'thread_${applicant.id}',
                            title: applicant.fullName,
                            subtitle: t.startNewConversation,
                            lastTimeLabelEn: 'Now',
                            lastTimeLabelAr: 'الآن',
                          );
                          Navigator.of(context).pushReplacementNamed(
                            AppRoutes.companyChatThread, 
                            arguments: thread
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
