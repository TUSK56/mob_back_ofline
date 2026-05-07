// Offline intro polish; replace with a remote LLM for production.

import 'dart:convert';

/// Offline “LinkedIn-style” polish: improves English and builds a professional
/// Arabic mirror (Fus’ha with Egyptian-leaning professional tone). For
/// production, replace [polish] with a remote LLM call.
class IntroPolishResult {
  const IntroPolishResult({required this.english, required this.arabic});

  final String english;
  final String arabic;

  String toEnglishJson() =>
      const JsonEncoder.withIndent('  ').convert({'about': english});

  String toArabicJson() =>
      const JsonEncoder.withIndent('  ').convert({'about': arabic});
}

final class IntroPolishService {
  IntroPolishService._();

  static Future<IntroPolishResult> polish(String rawEnglish) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    final en = _polishEnglish(rawEnglish);
    final ar = _professionalArabicMirror(en, rawEnglish);
    return IntroPolishResult(english: en, arabic: ar);
  }

  static String _polishEnglish(String raw) {
    var s = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
    s = s.replaceAll(RegExp(r'\n\s*\n'), '\n\n');
    if (s.isEmpty) {
      return 'Results-driven professional focused on clear execution, '
          'collaboration, and measurable impact. Open to opportunities where '
          'I can grow while contributing to products users trust.';
    }
    s = s.replaceAllMapped(RegExp(r'\bi\b'), (_) => 'I');
    s = s[0].toUpperCase() + s.substring(1);
    if (!RegExp(r'[.!?]"?$').hasMatch(s.trim())) {
      s = '${s.trim()}.';
    }
    if (s.length < 80) {
      s = '$s I bring ownership, clarity, and strong collaboration to every initiative.';
    }
    return s;
  }

  static String _professionalArabicMirror(String polishedEn, String rawEn) {
    final combined = '${polishedEn.toLowerCase()} ${rawEn.toLowerCase()}';
    if (combined.contains('nomad') && combined.contains('stripe')) {
      return 'تُعد Nomad منصّة برمجية لإطلاق وإدارة الأعمال عبر الإنترنت. '
          'يعتمد ملايين الشركات على أدوات Stripe لقبول المدفوعات والتوسّع '
          'عالميًا وإدارة أعمالها رقميًا بكفاءة.\n\n'
          'ظلّ Stripe في مقدمة توسيع التجارة الإلكترونية، ويسعى إلى تمكين '
          'النمو الاقتصادي الرقمي من خلال أدوات موثوقة وقابلة للتوسّع. '
          'رسالتنا هي دعم ازدهار اقتصاد الإنترنت عبر حلول دقيقة تلبي احتياجات الأعمال.';
    }

    final chips = _skillChipsArabic(combined);

    final buffer = StringBuffer()
      ..write('أقدّم نسخة احترافية موجزة من ملفي التعريفي بأسلوب واثق وواضح، ')
      ..write('مع الحفاظ على المعنى والأثر المهني نفسهما. ');

    if (chips.isNotEmpty) {
      buffer.write('أجمع بين ');
      buffer.write(chips.join('، '));
      buffer.write(' لتحقيق جودة تنفيذ عالية وتجربة استخدام قوية. ');
    }

    buffer.write(
      'أسهم باندماج فعّال مع الفرق، وأسلّم مخرجات يمكن الاعتماد عليها '
      'لدعم أهداف المؤسسة وثقة المستخدمين.',
    );

    return buffer.toString().trim();
  }

  static List<String> _skillChipsArabic(String lower) {
    final out = <String>[];
    void add(String a) {
      if (!out.contains(a)) out.add(a);
    }

    if (lower.contains('flutter')) add('Flutter');
    if (lower.contains('dart')) add('Dart');
    if (lower.contains('ui/ux') || lower.contains('ux')) add('UI/UX');
    if (lower.contains('data')) add('Data Analysis');
    if (lower.contains('internship')) add('Internship');
    if (lower.contains('mobile')) add('تطبيقات الجوال');
    if (lower.contains('team')) add('العمل الجماعي');
    if (lower.contains('product')) add('التفكير المنتجي');
    if (out.length > 5) return out.take(5).toList();
    if (out.isEmpty) add('الالتزام بالجودة والوضوح');
    return out;
  }
}
