/// The [MessageThread] model represents a distinct conversation summary.
/// It tracks the sender, latest subtitle, and localized timestamps.
final class MessageThread {
  /// Consructs a new [MessageThread].
  const MessageThread({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.lastTimeLabelEn,
    required this.lastTimeLabelAr,
  });

  final String id;
  final String title;
  final String subtitle;
  final String lastTimeLabelEn;
  final String lastTimeLabelAr;

  static MessageThread mock() => const MessageThread(
        id: 'thread_1',
        title: 'Jan Mayer',
        subtitle: 'We want to invite you for a quick interview...',
        lastTimeLabelEn: '12 mins ago',
        lastTimeLabelAr: 'منذ ١٢ دقيقة',
      );

  static List<MessageThread> mockList() => [];
}
