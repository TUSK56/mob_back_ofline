import 'package:flutter/material.dart';
import '../../../shared/l10n/app_localizations.dart';
import '../../../shared/utils/image_helper.dart';

class ChatThreadScreen extends StatefulWidget {
  final String name;
  final String image;

  const ChatThreadScreen({
    super.key,
    required this.name,
    required this.image,
  });

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  ImageProvider? get _peerAvatar => getAppImageProvider(widget.image.trim());

  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = []; // تبدأ فارغة دائماً

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add({
          "isMe": true,
          "text": _messageController.text.trim(),
          "time": _getCurrentTime(),
        });
        _messageController.clear();
      });
    }
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return "${now.hour}:${now.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: _peerAvatar,
              child: _peerAvatar == null ? const Icon(Icons.person, size: 18) : null,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.name,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                Text(t.tr(en: "Online", ar: "متصل"),
                    style: const TextStyle(color: Colors.green, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Divider(color: Theme.of(context).dividerColor.withValues(alpha: 0.12), height: 1),
          Expanded(
            child: _messages.isEmpty 
              ? _buildEmptyChat(t)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  itemCount: _messages.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) return _buildHeader();
                    final msg = _messages[index - 1];
                    return _buildMessageBubble(context, msg);
                  },
                ),
          ),
          _buildMessageInput(context, t),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildEmptyChat(AppLocalizations t) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildHeader(),
          Text(
            t.tr(en: "No messages yet. Say hi!", ar: "لا توجد رسائل بعد. قل مرحباً!"),
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, Map<String, dynamic> msg) {
    bool isMe = msg["isMe"];

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe)
            CircleAvatar(
              radius: 18,
              backgroundImage: _peerAvatar,
              child: _peerAvatar == null ? const Icon(Icons.person, size: 18) : null,
            ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isMe
                        ? Theme.of(context).colorScheme.primary
                        : (Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(msg["text"],
                      style: TextStyle(
                          color: isMe
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface)),
                ),
                const SizedBox(height: 4),
                Text(msg["time"],
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38), fontSize: 10)),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context, AppLocalizations t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(30)),
        child: Row(
          children: [
            IconButton(
                icon: Icon(Icons.attach_file, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54)),
                onPressed: () {}),
            Expanded(
              child: TextField(
                controller: _messageController,
                onChanged: (val) => setState(() {}),
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                    hintText: t.tr(en: "Type a message", ar: "اكتب رسالة"),
                    hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38)),
                    border: InputBorder.none),
              ),
            ),
            IconButton(
                icon: Icon(Icons.send,
                    color: _messageController.text.isEmpty
                        ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24)
                        : Theme.of(context).colorScheme.primary),
                onPressed: _messageController.text.isEmpty ? null : _sendMessage),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: _peerAvatar,
            child: _peerAvatar == null ? const Icon(Icons.person, size: 40) : null,
          ),
          const SizedBox(height: 10),
          Text(widget.name,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
