// [ChangeNotifier] holding company profile, jobs, and contacts.

import 'package:flutter/foundation.dart';
import 'dart:convert';

import '../models/contact_entry.dart';
import '../models/job.dart';
import '../services/session_manager.dart';

/// The [CompanyStore] acts as the central state management layer for the application.
/// It uses the [ChangeNotifier] mixin to broadcast updates to the UI whenever
/// the company's profile, job listings, or contact details change.
class CompanyStore extends ChangeNotifier {
  CompanyStore._();

  /// The static singleton instance of [CompanyStore].
  /// This prevents multiple and conflicting instances from being created.
  static final CompanyStore instance = CompanyStore._();

  // --- Company Basic Details ---
  String _companyName = '';
  String _website = '';
  String _staff = '';
  String _industry = '';

  // --- Company Extended Details ---
  List<String> _locations = [];
  List<String> _techStack = [];

  // --- Date Founded ---
  int _foundedDay = 0;
  int _foundedMonth = 0;
  int _foundedYear = 0;

  // --- Category and Benefits ---
  String _classification = '';
  List<String> _benefits = [];

  // --- Registration Data ---
  String _commercialRegister = '';
  String _nationalNumber = '';
  String? _customProfileImage;
  String _companyId = '';

  // Public getters to access state securely
  String get companyId => _companyId;
  String get companyName => _companyName;
  String get website => _website;
  String get staff => _staff;
  String get industry => _industry;
  
  /// Returns an unmodifiable list of locations to prevent accidental mutations.
  List<String> get locations => List.unmodifiable(_locations);
  
  /// Returns an unmodifiable list of the underlying technology stack.
  List<String> get techStack => List.unmodifiable(_techStack);
  
  int get foundedDay => _foundedDay;
  int get foundedMonth => _foundedMonth;
  int get foundedYear => _foundedYear;

  String get classification => _classification;
  List<String> get benefits => List.unmodifiable(_benefits);

  String get commercialRegister => _commercialRegister;
  String get nationalNumber => _nationalNumber;

  String? get companyProfileImage => _customProfileImage;

  String _aboutEn = '';
  String _aboutAr = '';

  String get companyAboutEn => _aboutEn;
  String get companyAboutAr => _aboutAr;

  /// Updates the localized company introduction and notifies UI listeners.
  /// 
  /// [english] The introduction text in English.
  /// [arabic] The introduction text in Arabic.
  void setCompanyIntro({required String english, required String arabic}) {
    _aboutEn = english;
    _aboutAr = arabic;
    notifyListeners();
  }

  void setRegistrationData({
    String? companyId,
    String? companyName,
    String? customProfileImage,
    String? commercialRegister,
    String? nationalNumber,
    String? email,
  }) {
    if (companyId != null) _companyId = companyId;
    if (companyName != null && companyName.isNotEmpty) _companyName = companyName;
    if (customProfileImage != null) _customProfileImage = customProfileImage;
    if (commercialRegister != null) _commercialRegister = commercialRegister;
    if (nationalNumber != null) _nationalNumber = nationalNumber;
    
    if (email != null && email.isNotEmpty) {
      final existingEmailIndex = _contacts.indexWhere((c) => c.name.toLowerCase() == 'email' || c.name == 'البريد الإلكتروني');
      if (existingEmailIndex >= 0) {
         _contacts[existingEmailIndex] = _contacts[existingEmailIndex].copyWith(value: email);
      } else {
         _contacts.add(ContactEntry(name: 'Email', value: email));
      }
    }
    notifyListeners();
  }

  /// Updates the master profile variables and alerts the app to redraw.
  void updateProfile({
    required String name,
    required String website,
    required String staff,
    required String industry,
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
  }) {
    _companyName = name;
    _website = website;
    _staff = staff;
    _industry = industry;
    _aboutEn = aboutEn;
    _aboutAr = aboutAr;
    _locations = List.from(locations.toSet());
    _techStack = List.from(techStack.toSet());
    _foundedDay = foundedDay;
    _foundedMonth = foundedMonth;
    _foundedYear = foundedYear;
    _classification = classification;
    _benefits = List.from(benefits.toSet());
    _commercialRegister = commercialRegister;
    _nationalNumber = nationalNumber;
    notifyListeners();
  }

  Future<void> initFromSession() async {
    final data = await SessionManager.getCompanyData();
    if (data['name'] != null) _companyName = data['name']!;
    if (data['id'] != null) _companyId = data['id']!;
    if (data['photo'] != null) _customProfileImage = data['photo']!;
    notifyListeners();
  }

  Future<void> syncFromMap(Map<String, dynamic> data) async {
    if (data['id'] != null && data['id'].toString().trim().isNotEmpty) {
      _companyId = data['id'].toString().trim();
    } else if (data['_id'] != null &&
        data['_id'].toString().trim().isNotEmpty) {
      _companyId = data['_id'].toString().trim();
    }
    if (data['staff'] != null) _staff = data['staff'].toString();
    if (data['industry'] != null) _industry = data['industry'].toString();
    if (data['website'] != null) _website = data['website'].toString();
    
    // In the backend 'about' is a single field. For now we sync it to both locales 
    // unless the backend eventually returns separate fields.
    if (data['about'] != null) {
      _aboutEn = data['about'].toString();
      _aboutAr = data['about'].toString();
    }
    
    if (data['locations'] is List) {
      _locations = List<String>.from(data['locations']);
    } else if (data['locationsCsv'] != null) {
       _locations = data['locationsCsv'].toString().split(',').where((s) => s.isNotEmpty).toList();
    }

    if (data['techStack'] is List) {
      _techStack = List<String>.from(data['techStack']);
    }

    if (data['foundedDay'] != null) _foundedDay = int.tryParse(data['foundedDay'].toString()) ?? 0;
    if (data['foundedMonth'] != null) _foundedMonth = int.tryParse(data['foundedMonth'].toString()) ?? 0;
    if (data['foundedYear'] != null) _foundedYear = int.tryParse(data['foundedYear'].toString()) ?? 0;
    
    if (data['classification'] != null) _classification = data['classification'].toString();
    
    if (data['benefits'] is List) {
      _benefits = List<String>.from(data['benefits']);
    }

    if (data['commercialRegister'] != null) _commercialRegister = data['commercialRegister'].toString();
    if (data['nationalNumber'] != null) _nationalNumber = data['nationalNumber'].toString();
    
    if (data['contactsJson'] != null) {
       try {
         final List<dynamic> decoded = jsonDecode(data['contactsJson'].toString());
         _contacts.clear();
         for (final item in decoded) {
           if (item is Map) {
             _contacts.add(ContactEntry(
               name: item['name']?.toString() ?? '',
               value: item['value']?.toString() ?? '',
             ));
           }
         }
       } catch (_) {}
    }

    notifyListeners();
  }

  Future<void> loadFromSession(Map<String, dynamic> data) async {
    _staff = data['staff'] as String? ?? '';
    _industry = data['industry'] as String? ?? '';
    _website = data['website'] as String? ?? '';
    _aboutEn = data['aboutEn'] as String? ?? '';
    _aboutAr = data['aboutAr'] as String? ?? '';
    _locations = List<String>.from(data['locations'] as List? ?? []);
    _techStack = List<String>.from(data['techStack'] as List? ?? []);
    _foundedDay = data['foundedDay'] as int? ?? 0;
    _foundedMonth = data['foundedMonth'] as int? ?? 0;
    _foundedYear = data['foundedYear'] as int? ?? 0;
    _classification = data['classification'] as String? ?? '';
    _benefits = List<String>.from(data['benefits'] as List? ?? []);
    _commercialRegister = data['commercialRegister'] as String? ?? '';
    _nationalNumber = data['nationalNumber'] as String? ?? '';
    
    // Load contacts
    try {
      final contactsJson = data['contacts'] as String? ?? '';
      if (contactsJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(contactsJson);
        _contacts.clear();
        for (final item in decoded) {
          if (item is Map) {
            _contacts.add(ContactEntry(
              name: item['name']?.toString() ?? '',
              value: item['value']?.toString() ?? '',
            ));
          }
        }
      }
    } catch (_) {}

    notifyListeners();
  }

  // --- Associated Entities: Jobs & Contacts ---
  
  /// Holds the list of dynamically managed jobs for the company.
  final List<Job> _jobs = [];
  
  /// Holds contact details like social links and emails.
  final List<ContactEntry> _contacts = [];

  List<Job> get jobs => List<Job>.unmodifiable(_jobs);
  List<ContactEntry> get contacts => List<ContactEntry>.unmodifiable(_contacts);

  /// Retrieves a specific job by its ID and returns an empty placeholder if missing.
  Job jobById(String id) {
    return _jobs.firstWhere(
      (job) => job.id == id,
      orElse: () => Job(
        id: '',
        companyId: '',
        title: '',
        companyName: '',
        location: '',
        employmentType: '',
        classification: '',
        salaryRange: '',
      ),
    );
  }

  /// Inserts a new job at the top of the list or updates an existing one if ID matches.
  void saveJob(Job job) {
    final index = _jobs.indexWhere((j) => j.id == job.id);
    if (index >= 0) {
      _jobs[index] = job;
    } else {
      _jobs.insert(0, job);
      // Generate mock applicants for the new job to demonstrate the pipeline
      // Mock generation disabled to keep stats clean for backend
      /*
      RecruitmentSyncStore.instance.generateMockApplicants(
        job.id,
        job.title,
        job.companyName,
      );
      */
    }
    notifyListeners();
  }

  /// Clears all jobs from the store.
  void clearJobs() {
    _jobs.clear();
    notifyListeners();
  }

  /// Deletes a job from the current list using its unique ID.
  /// Returns `true` if the deletion triggered an item removal and UI update.
  bool deleteJob(String id) {
    final before = _jobs.length;
    _jobs.removeWhere((job) => job.id == id);
    final changed = _jobs.length != before;
    if (changed) {
      notifyListeners();
    }
    return changed;
  }

  void addContact(ContactEntry contact) {
    _contacts.add(contact);
    _saveContacts();
    notifyListeners();
  }

  void updateContact(int index, ContactEntry updated) {
    if (index < 0 || index >= _contacts.length) return;
    _contacts[index] = updated;
    _saveContacts();
    notifyListeners();
  }

  void removeContact(int index) {
    if (index < 0 || index >= _contacts.length) return;
    _contacts.removeAt(index);
    _saveContacts();
    notifyListeners();
  }

  void _saveContacts() {
    SessionManager.saveCompanyContacts(
      _contacts.map((c) => {'name': c.name, 'value': c.value}).toList(),
    );
  }

  void clear() {
    _companyName = '';
    _website = '';
    _staff = '';
    _industry = '';
    _aboutEn = '';
    _aboutAr = '';
    _locations = [];
    _techStack = [];
    _foundedDay = 0;
    _foundedMonth = 0;
    _foundedYear = 0;
    _classification = '';
    _benefits = [];
    _commercialRegister = '';
    _nationalNumber = '';
    _customProfileImage = null;
    _companyId = '';
    _jobs.clear();
    _contacts.clear();
    notifyListeners();
  }
}
