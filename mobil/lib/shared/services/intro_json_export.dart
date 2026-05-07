// Writes intro JSON files next to app documents (matches asset shape).

import 'dart:convert';
import 'dart:io';

/// Writes `about_intro_en.json` and `about_intro_ar.json` next to app documents
/// (same shape as bundled assets).
final class IntroJsonExport {
  IntroJsonExport._();

  static Future<String> saveBoth({
    required String englishAbout,
    required String arabicAbout,
  }) async {
    final dir = Directory.current;
    final enPath = '${dir.path}${Platform.pathSeparator}about_intro_en.json';
    final arPath = '${dir.path}${Platform.pathSeparator}about_intro_ar.json';
    final enc = const JsonEncoder.withIndent('  ');
    await File(enPath).writeAsString(enc.convert({'about': englishAbout}));
    await File(arPath).writeAsString(enc.convert({'about': arabicAbout}));
    return dir.path;
  }
}
