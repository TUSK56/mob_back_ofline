import 'package:flutter/material.dart';
import '../../../constants/app_images.dart';
import '../../../shared/l10n/app_localizations.dart';
import '../../../shared/state/recruitment_sync_store.dart';
import '../../../shared/utils/image_helper.dart';
import 'chat_thread_screen.dart';
import 'new_chat_screen.dart';

class MessagesListScreen extends StatefulWidget {
  const MessagesListScreen({super.key});

  @override
  State<MessagesListScreen> createState() => _MessagesListScreenState();
}

class _MessagesListScreenState extends State<MessagesListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final store = RecruitmentSyncStore.instance;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NewChatScreen()),
        ),
        backgroundColor: const Color(0xFFDDE6FF),
        elevation: 4,
        child: const Icon(Icons.add, color: Color(0xFF011931)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                t.messages,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              _buildSearchBar(context, t),
              const SizedBox(height: 20),
              Expanded(
                child: AnimatedBuilder(
                  animation: store,
                  builder: (context, _) {
                    // Filter real messages from store
                    final messages = store.messages.where((m) => 
                      m.text.toLowerCase().contains(_searchQuery)
                    ).toList();

                    if (messages.isEmpty) {
                      return _buildEmptyState(t);
                    }

                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: messages.length,
                      separatorBuilder: (context, index) => Divider(
                        color: Theme.of(context).dividerColor.withValues(alpha: 0.12),
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        return _buildMessageItem(
                          context,
                          name: msg.fromCompany ? "Company Support" : "User",
                          message: msg.text,
                          time: "${msg.createdAt.hour}:${msg.createdAt.minute.toString().padLeft(2, '0')}",
                          image: msg.fromCompany
                              ? AppImages.companyProfile2
                              : (store.profileImage ?? AppImages.companyProfile2),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations t) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(
            t.tr(en: "No messages yet", ar: "لا توجد رسائل بعد"),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, AppLocalizations t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.12)),
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54)),
          hintText: t.tr(en: "Search messages", ar: "البحث في الرسائل"),
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38)),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildMessageItem(
    BuildContext context, {
    required String name,
    required String message,
    required String time,
    required String image,
  }) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatThreadScreen(name: name, image: image),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Builder(
              builder: (context) {
                final avatar = getAppImageProvider(image);
                return CircleAvatar(
                  radius: 28,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  backgroundImage: avatar,
                  child: avatar == null ? const Icon(Icons.person, size: 28) : null,
                );
              },
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(name, style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16, 
                        fontWeight: FontWeight.bold
                      )),
                      Text(time, style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38), 
                        fontSize: 12
                      )),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), 
                      fontSize: 14
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
