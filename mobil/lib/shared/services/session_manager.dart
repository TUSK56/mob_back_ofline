import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SessionManager {
  static const String _keyIsLoggedInCompany = 'is_logged_in_company';
  static const String _keyCompanyEmail = 'company_email';
  static const String _keyCompanyName = 'company_name';
  static const String _keyCompanyPhoto = 'company_photo';

  static const String _keyIsLoggedInUser = 'is_logged_in_user';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserName = 'user_name';
  static const String _keyUserPhoto = 'user_photo';

  static Future<void> saveCompanySession({
    required String email,
    required String name,
    required String id,
    String? photoPath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedInCompany, true);
    await prefs.setString(_keyCompanyEmail, email);
    await prefs.setString(_keyCompanyName, name);
    await prefs.setString('company_id', id);
    if (photoPath != null) {
      await prefs.setString(_keyCompanyPhoto, photoPath);
    }
  }

  static Future<bool> isCompanyLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedInCompany) ?? false;
  }

  static Future<Map<String, String?>> getCompanyData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString(_keyCompanyEmail),
      'name': prefs.getString(_keyCompanyName),
      'id': prefs.getString('company_id'),
      'photo': prefs.getString(_keyCompanyPhoto),
    };
  }

  static Future<void> saveCompanyPhoto(String photoPath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCompanyPhoto, photoPath);
  }

  static Future<void> logoutCompany() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedInCompany);
    await prefs.remove(_keyCompanyEmail);
    await prefs.remove(_keyCompanyName);
    await prefs.remove('company_id');
    await prefs.remove(_keyCompanyPhoto);
    await prefs.remove('company_staff');
    await prefs.remove('company_industry');
    await prefs.remove('company_aboutEn');
    await prefs.remove('company_aboutAr');
    await prefs.remove('company_locations');
    await prefs.remove('company_techStack');
    await prefs.remove('company_foundedDay');
    await prefs.remove('company_foundedMonth');
    await prefs.remove('company_foundedYear');
    await prefs.remove('company_classification');
    await prefs.remove('company_benefits');
    await prefs.remove('company_commercialRegister');
    await prefs.remove('company_nationalNumber');
    await prefs.remove('company_website');
    await prefs.remove('company_contacts_json');
    await prefs.remove('auth_token');
  }

  static Future<void> saveCompanyFullProfile({
    required String staff,
    required String industry,
    required String website,
    required String aboutEn,
    required String aboutAr,
    required List<String> locations,
    required List<String> techStack,
    required int foundedDay,
    required int foundedMonth,
    required int foundedYear,
    required String classification,
    required List<String> benefits,
    required String commercialRegister,
    required String nationalNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('company_staff', staff);
    await prefs.setString('company_industry', industry);
    await prefs.setString('company_website', website);
    await prefs.setString('company_aboutEn', aboutEn);
    await prefs.setString('company_aboutAr', aboutAr);
    await prefs.setStringList('company_locations', locations);
    await prefs.setStringList('company_techStack', techStack);
    await prefs.setInt('company_foundedDay', foundedDay);
    await prefs.setInt('company_foundedMonth', foundedMonth);
    await prefs.setInt('company_foundedYear', foundedYear);
    await prefs.setString('company_classification', classification);
    await prefs.setStringList('company_benefits', benefits);
    await prefs.setString('company_commercialRegister', commercialRegister);
    await prefs.setString('company_nationalNumber', nationalNumber);
  }

  static Future<void> saveCompanyContacts(List<Map<String, String>> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('company_contacts_json', jsonEncode(contacts));
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<Map<String, dynamic>> getCompanyFullProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'staff': prefs.getString('company_staff') ?? '',
      'industry': prefs.getString('company_industry') ?? '',
      'website': prefs.getString('company_website') ?? '',
      'aboutEn': prefs.getString('company_aboutEn') ?? '',
      'aboutAr': prefs.getString('company_aboutAr') ?? '',
      'locations': prefs.getStringList('company_locations') ?? <String>[],
      'techStack': prefs.getStringList('company_techStack') ?? <String>[],
      'foundedDay': prefs.getInt('company_foundedDay') ?? 0,
      'foundedMonth': prefs.getInt('company_foundedMonth') ?? 0,
      'foundedYear': prefs.getInt('company_foundedYear') ?? 0,
      'classification': prefs.getString('company_classification') ?? '',
      'benefits': prefs.getStringList('company_benefits') ?? <String>[],
      'commercialRegister': prefs.getString('company_commercialRegister') ?? '',
      'nationalNumber': prefs.getString('company_nationalNumber') ?? '',
      'contacts': prefs.getString('company_contacts_json') ?? '',
    };
  }

  static Future<void> saveUserSession({
    required String email,
    required String name,
    String? photoPath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedInUser, true);
    await prefs.setString(_keyUserEmail, email);
    await prefs.setString(_keyUserName, name);
    if (photoPath != null) {
      await prefs.setString(_keyUserPhoto, photoPath);
    }
  }

  static Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedInUser) ?? false;
  }

  static Future<Map<String, String?>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString(_keyUserEmail),
      'name': prefs.getString(_keyUserName),
      'photo': prefs.getString(_keyUserPhoto),
    };
  }

  static Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedInUser);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserPhoto);
    await prefs.remove('auth_token');
    await prefs.remove('user_phone');
    await prefs.remove('user_location');
    await prefs.remove('user_about');
    await prefs.remove('user_title');
    await prefs.remove('user_role');
    await prefs.remove('user_skills');
    await prefs.remove('user_education_json');
    await prefs.remove('user_experience_json');
    await prefs.remove('user_social_links_json');
    await prefs.remove('user_portfolio_images');
  }

  static Future<void> saveUserFullProfile({
    required String phone,
    required String location,
    required String about,
    required String title,
    required String role,
    required List<String> skills,
    required List<Map<String, String>> education,
    required List<Map<String, String>> experience,
    required List<Map<String, String>> socialLinks,
    required List<String> portfolioImages,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_phone', phone);
    await prefs.setString('user_location', location);
    await prefs.setString('user_about', about);
    await prefs.setString('user_title', title);
    await prefs.setString('user_role', role);
    await prefs.setStringList('user_skills', skills);
    await prefs.setString('user_education_json', jsonEncode(education));
    await prefs.setString('user_experience_json', jsonEncode(experience));
    await prefs.setString('user_social_links_json', jsonEncode(socialLinks));
    await prefs.setStringList('user_portfolio_images', portfolioImages);
  }

  static Future<Map<String, dynamic>> getUserFullProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'phone': prefs.getString('user_phone') ?? '',
      'location': prefs.getString('user_location') ?? '',
      'about': prefs.getString('user_about') ?? '',
      'title': prefs.getString('user_title') ?? '',
      'role': prefs.getString('user_role') ?? 'Job Seeker',
      'skills': prefs.getStringList('user_skills') ?? <String>[],
      'education': prefs.getString('user_education_json') ?? '',
      'experience': prefs.getString('user_experience_json') ?? '',
      'socialLinks': prefs.getString('user_social_links_json') ?? '',
      'portfolioImages': prefs.getStringList('user_portfolio_images') ?? <String>[],
    };
  }
}
