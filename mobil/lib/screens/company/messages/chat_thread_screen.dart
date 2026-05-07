// Message thread between company and candidate.

import 'package:flutter/material.dart';

import '../../../shared/l10n/app_localizations.dart';
import '../../../shared/models/message_thread.dart';
import '../../../shared/widgets/app_scaffold.dart';

class CompanyChatThreadScreen extends StatefulWidget {
  const CompanyChatThreadScreen({super.key, required this.thread});

  final MessageThread thread;

  @override
  State<CompanyChatThreadScreen> createState() =>
      _CompanyChatThreadScreenState();
}

class _CompanyChatThreadScreenState extends State<CompanyChatThreadScreen> {
  final _input = TextEditingController();
  final List<_Bubble> _bubbles = [
    _Bubble(
      text:
          'Hey Jake, I wanted to reach out because we saw your work contributions and were impressed by your work.',
      fromMe: false,
      time: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    _Bubble(
      text: 'We want to invite you for a quick interview', 
      fromMe: false,
      time: DateTime.now().subtract(const Duration(minutes: 4)),
    ),
    _Bubble(
      text:
          'Hi, sure I would love to. Thanks for taking the time to see my work!',
      fromMe: true,
      time: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
  ];

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _bubbles.add(_Bubble(text: text, fromMe: true, time: DateTime.now()));
      _input.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return AppScaffold(
      title: widget.thread.title,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _bubbles.length,
              itemBuilder: (_, i) => _ChatBubble(bubble: _bubbles[i]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    decoration: InputDecoration(
                      hintText: t.replyMessage,
                      prefixIcon: const Icon(Icons.attach_file),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filled(
                  onPressed: _send,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final class _Bubble {
  const _Bubble({required this.text, required this.fromMe, required this.time});

  final String text;
  final bool fromMe;
  final DateTime time;
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.bubble});

  final _Bubble bubble;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    final bg = bubble.fromMe
        ? cs.primary
        : cs.surfaceContainerHigh;
        
    final textColor = bubble.fromMe
        ? cs.onPrimary
        : cs.onSurface;

    final align = bubble.fromMe 
        ? AlignmentDirectional.centerEnd 
        : AlignmentDirectional.centerStart;
        
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      bottomLeft: Radius.circular(bubble.fromMe ? 20 : 4),
      bottomRight: Radius.circular(bubble.fromMe ? 4 : 20),
    );

    return Align(
      alignment: align,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Wrap(
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.end,
          runAlignment: WrapAlignment.end,
          children: [
            Text(
              bubble.text,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Text(
                TimeOfDay.fromDateTime(bubble.time).format(context),
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
