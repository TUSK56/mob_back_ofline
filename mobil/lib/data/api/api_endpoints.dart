// Base URL placeholder and REST path constants for the backend.

final class ApiEndpoints {
  const ApiEndpoints._();

  // Render deployment URL (can be overridden at build time).
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://jobito.runasp.net',
  );

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

