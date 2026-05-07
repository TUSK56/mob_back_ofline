import 'package:flutter/foundation.dart';

// Base URL and REST path constants for the backend.

final class ApiEndpoints {
  const ApiEndpoints._();

  // Local-first URL with platform-aware fallback.
  // Can always be overridden via --dart-define=API_BASE_URL=...
  static final String baseUrl = _resolveBaseUrl();

  static String _resolveBaseUrl() {
    const override = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (override.isNotEmpty) return override;
    if (kIsWeb) return 'http://localhost:3000';
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Physical Android phone should use PC LAN IP.
      // Override any time with: --dart-define=API_BASE_URL=http://<ip>:3000
      return 'http://192.168.1.5:3000';
    }
    return 'http://192.168.1.5:3000';
  }

  // Auth
  static const String login = '/api/auth/login';
  static const String googleLogin = '/api/auth/google';
  static const String register = '/api/auth/register';
  static const String profile = '/api/auth/profile';

  // Recruitment entities
  static const String jobs = '/api/jobs';
  static const String applications = '/api/applications';
  static const String applicationStatus = '/api/applications/{id}/status';
  static const String messages = '/api/messages';
  static const String notifications = '/api/notifications';
}

