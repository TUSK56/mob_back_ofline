import 'package:flutter/material.dart';
import '../../screens/user/profile/user_data.dart';

class RecruitmentJob {
  const RecruitmentJob({
    required this.id,
    required this.companyId,
    required this.title,
    required this.companyName,
    required this.location,
    required this.salaryRange,
    required this.type,
    required this.status,
    required this.classification,
    required this.tags,
    required this.publishedAt,
    this.description = '',
    this.responsibilities = const [],
    this.qualifications = const [],
    this.niceToHaves = const [],
    required this.benefits,
    this.logoIcon,
    this.companyLogoUrl,
    this.companyIndustry,
    this.capacity = 1,
    this.acceptedCount = 0,
    this.viewsCount = 0,
    this.deadline,
  });

  final String id;
  final String companyId;
  final String title;
  final String companyName;
  final String location;
  final String salaryRange;
  final String type;
  final String status;
  final String classification;
  final List<String> tags;
  final DateTime publishedAt;
  final String description;
  final List<String> responsibilities;
  final List<String> qualifications;
  final List<String> niceToHaves;
  final List<String> benefits;
  final IconData? logoIcon;
  final String? companyLogoUrl;
  final String? companyIndustry;
  final int capacity;
  final int acceptedCount;
  final int viewsCount;
  final DateTime? deadline;

  /// Gets the category (alias for classification for backward compatibility)
  String get category => classification;
}

class RecruitmentApplication {
  const RecruitmentApplication({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.companyName,
    required this.userName,
    required this.status,
    required this.updatedAt,
    this.gender,
    this.birthDate,
    this.languages = const [],
    this.about,
    this.experienceYears = 0,
    this.education,
    this.skills = const [],
    this.hasCv = false,
    this.cvUrl,
    this.cvFileName,
    this.email,
    this.phone,
    this.location,
  });

  final String id;
  final String jobId;
  final String jobTitle;
  final String companyName;
  final String userName;
  final String status;
  final DateTime updatedAt;
  final String? gender;
  final String? birthDate;
  final List<String> languages;
  final String? about;
  final int experienceYears;
  final String? education;
  final List<String> skills;
  final bool hasCv;
  final String? cvUrl;
  final String? cvFileName;
  final String? email;
  final String? phone;
  final String? location;

  RecruitmentApplication copyWith({String? status, DateTime? updatedAt}) {
    return RecruitmentApplication(
      id: id,
      jobId: jobId,
      jobTitle: jobTitle,
      companyName: companyName,
      userName: userName,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      gender: gender,
      birthDate: birthDate,
      languages: languages,
      about: about,
      experienceYears: experienceYears,
      education: education,
      skills: skills,
      hasCv: hasCv,
      cvUrl: cvUrl,
      cvFileName: cvFileName,
      email: email,
      phone: phone,
      location: location,
    );
  }
}

class RecruitmentMessage {
  const RecruitmentMessage({
    required this.id,
    required this.fromCompany,
    required this.text,
    required this.createdAt,
  });
  final String id;
  final bool fromCompany;
  final String text;
  final DateTime createdAt;
}

class ChatThread {
  final String name;
  final String image;
  String lastMessage;
  String time;
  ChatThread({
    required this.name,
    required this.image,
    required this.lastMessage,
    required this.time,
  });
}

class ServiceRequestPost {
  const ServiceRequestPost({
    required this.id,
    required this.title,
    required this.description,
    required this.budget,
    required this.requestedBy,
    required this.createdAt,
  });
  final String id;
  final String title;
  final String description;
  final String budget;
  final String requestedBy;
  final DateTime createdAt;
}

class RecruitmentSyncStore extends ChangeNotifier {
  RecruitmentSyncStore._();
  static final RecruitmentSyncStore instance = RecruitmentSyncStore._();

  static const List<String> categories = [
    'All',
    'Technical',
    'Non-Technical',
    'Service',
    'Tradesman',
  ];

  static const List<String> classifications = categories;

  static const List<String> salaryRanges = [
    'All',
    '10k - 20k',
    '20k - 30k',
    '30k - 45k',
    'Negotiable',
  ];

  static const List<String> egyptGovernorates = [
    'All',
    'Cairo',
    'Giza',
    'Alexandria',
    'Dakahlia',
    'Red Sea',
    'Beheira',
    'Fayoum',
    'Gharbia',
    'Ismailia',
    'Monufia',
    'Minya',
    'Qalyubia',
    'New Valley',
    'Sharqia',
    'Suez',
    'Aswan',
    'Assiut',
    'Beni Suef',
    'Port Said',
    'Damietta',
    'South Sinai',
    'Kafr El Sheikh',
    'Matrouh',
    'Luxor',
    'Qena',
    'Sohag',
    'North Sinai',
    'Remote',
  ];

  final List<RecruitmentJob> _jobs = <RecruitmentJob>[];
  final List<RecruitmentApplication> _applications = <RecruitmentApplication>[];
  final List<RecruitmentMessage> _messages = <RecruitmentMessage>[];
  final List<ChatThread> _tradesmanChatThreads = <ChatThread>[];
  final Set<String> _savedJobIds = <String>{};
  final List<ServiceRequestPost> _serviceRequests = <ServiceRequestPost>[];

  String _currentUserName = 'User';
  String _currentUserEmail = '';
  String _currentUserPhone = '';
  String _currentUserLocation = '';
  String _currentUserGender = '';
  String _currentUserAbout = '';
  String _currentUserIndustry = '';
  String _currentUserTitle = '';
  String _userRole = 'Job Seeker';
  String? _profileImage;
  String _searchQuery = '';
  String _filterType = 'All';
  String _filterLocation = 'All';
  String _filterClassification = 'All';
  String _filterSalaryRange = 'All';

  List<String> _currentUserSkills = [];
  List<Map<String, String>> _currentUserEducation = [];
  List<Map<String, String>> _currentUserExperience = [];
  List<Map<String, String>> _socialLinks = [];
  List<String> _portfolioImages = [];

  List<RecruitmentJob> get jobs => List.unmodifiable(_jobs);
  List<RecruitmentApplication> get applications =>
      List.unmodifiable(_applications);
  List<RecruitmentMessage> get messages => List.unmodifiable(_messages);
  List<ChatThread> get tradesmanChatThreads =>
      List.unmodifiable(_tradesmanChatThreads);
  Set<String> get savedJobIds => Set.unmodifiable(_savedJobIds);
  List<ServiceRequestPost> get serviceRequests =>
      List.unmodifiable(_serviceRequests);

  String get currentUserName => _currentUserName;
  String get currentUserEmail => _currentUserEmail;
  String get currentUserPhone => _currentUserPhone;
  String get currentUserLocation => _currentUserLocation;
  String get currentUserAbout => _currentUserAbout;
  String get currentUserIndustry => _currentUserIndustry;
  String get currentUserTitle => _currentUserTitle;
  String get userRole => _userRole;
  String? get profileImage => _profileImage;
  String get filterType => _filterType;
  String get filterLocation => _filterLocation;
  String get filterClassification => _filterClassification;
  String get filterSalaryRange => _filterSalaryRange;
  String get currentUserGender => _currentUserGender;

  /// Gets the filter category (alias for filterClassification)
  String get filterCategory => _filterClassification;

  List<String> get currentUserSkills => _currentUserSkills;
  List<Map<String, String>> get currentUserEducation => _currentUserEducation;
  List<Map<String, String>> get currentUserExperience => _currentUserExperience;
  List<Map<String, String>> get socialLinks => _socialLinks;
  List<String> get portfolioImages => _portfolioImages;

  List<RecruitmentJob> get savedJobs =>
      _jobs.where((item) => _savedJobIds.contains(item.id)).toList();

  List<RecruitmentJob> get filteredJobs {
    if (_searchQuery.isEmpty &&
        _filterType == 'All' &&
        _filterLocation == 'All' &&
        _filterClassification == 'All' &&
        _filterSalaryRange == 'All') {
      return _jobs;
    }
    return _jobs.where((job) {
      final matchesQuery =
          _searchQuery.isEmpty ||
          job.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          job.companyName.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesType = _filterType == 'All' || job.type == _filterType;
      final matchesLocation =
          _filterLocation == 'All' || job.location == _filterLocation;
      final matchesClassification =
          _filterClassification == 'All' ||
          job.classification == _filterClassification;
      final matchesSalary =
          _filterSalaryRange == 'All' || job.salaryRange == _filterSalaryRange;

      return matchesQuery &&
          matchesType &&
          matchesLocation &&
          matchesClassification &&
          matchesSalary;
    }).toList();
  }

  void toggleSaveJob(String jobId) {
    if (_savedJobIds.contains(jobId)) {
      _savedJobIds.remove(jobId);
    } else {
      _savedJobIds.add(jobId);
    }
    notifyListeners();
  }

  void updateCurrentUser({
    String? name,
    String? email,
    String? phone,
    String? location,
    String? photoUrl,
  }) {
    if (name != null) {
      _currentUserName = name;
      UserProfileData.fullName = name;
    }
    if (email != null) {
      _currentUserEmail = email;
      UserProfileData.email = email;
    }
    if (phone != null) {
      _currentUserPhone = phone;
      UserProfileData.phone = phone;
    }
    if (location != null) {
      _currentUserLocation = location;
      UserProfileData.location = location;
    }
    if (photoUrl != null && photoUrl.isNotEmpty) {
      _profileImage = photoUrl;
      UserProfileData.profileImage = photoUrl;
    }
    notifyListeners();
  }

  void updateUserProfile({
    required String fullName,
    required String title,
    String? email,
    String? phone,
    String? location,
    String? about,
    String? industry,
    List<String>? skills,
    List<Map<String, String>>? education,
    List<Map<String, String>>? experience,
    List<Map<String, String>>? socialLinks,
    String? role,
    List<String>? portfolioImages,
    String? gender,
  }) {
    _currentUserName = fullName;
    UserProfileData.fullName = fullName;

    _currentUserTitle = title;
    UserProfileData.jobTitle = title;

    if (email != null) {
      _currentUserEmail = email;
      UserProfileData.email = email;
    }
    if (phone != null) {
      _currentUserPhone = phone;
      UserProfileData.phone = phone;
    }
    if (location != null) {
      _currentUserLocation = location;
      UserProfileData.location = location;
    }
    if (about != null) {
      _currentUserAbout = about;
      UserProfileData.aboutMe = about;
    }
    if (industry != null) _currentUserIndustry = industry;

    if (skills != null) {
      _currentUserSkills = skills;
      UserProfileData.skills = skills;
    }
    if (education != null) {
      _currentUserEducation = education;
      UserProfileData.education = education;
    }
    if (experience != null) {
      _currentUserExperience = experience;
      UserProfileData.experiences = experience;
    }
    if (socialLinks != null) {
      _socialLinks = socialLinks;
      UserProfileData.socialLinks = socialLinks;
    }
    if (role != null) _userRole = role;

    if (portfolioImages != null) {
      _portfolioImages = portfolioImages;
      UserProfileData.portfolioImages = portfolioImages;
    }

    if (gender != null) {
      _currentUserGender = gender;
      UserProfileData.gender = gender;
    }

    notifyListeners();
  }

  void updateFilters({
    String? searchQuery,
    String? type,
    String? location,
    String? classification,
    String? salaryRange,
  }) {
    if (searchQuery != null) _searchQuery = searchQuery;
    if (type != null) _filterType = type;
    if (location != null) _filterLocation = location;
    if (classification != null) _filterClassification = classification;
    if (salaryRange != null) _filterSalaryRange = salaryRange;
    notifyListeners();
  }

  void updateTradesmanChat(String name, String image, String text) {
    final existingIndex = _tradesmanChatThreads.indexWhere(
      (t) => t.name == name,
    );
    final now = DateTime.now();
    final timeStr = "${now.hour}:${now.minute.toString().padLeft(2, '0')}";
    if (existingIndex != -1) {
      _tradesmanChatThreads[existingIndex].lastMessage = text;
      _tradesmanChatThreads[existingIndex].time = timeStr;
      final thread = _tradesmanChatThreads.removeAt(existingIndex);
      _tradesmanChatThreads.insert(0, thread);
    } else {
      _tradesmanChatThreads.insert(
        0,
        ChatThread(name: name, image: image, lastMessage: text, time: timeStr),
      );
    }
    notifyListeners();
  }

  void replaceFromRemote({
    required List<Map<String, dynamic>> jobs,
    required List<Map<String, dynamic>> applications,
    required List<Map<String, dynamic>> messages,
  }) {
    _jobs.clear();
    for (var item in jobs) {
      final companyMap = item['company'] is Map
          ? Map<String, dynamic>.from(item['company'] as Map)
          : <String, dynamic>{};
      _jobs.add(
        RecruitmentJob(
          id: item['id']?.toString() ?? '',
          companyId:
              item['companyId']?.toString() ??
              item['company_id']?.toString() ??
              item['ownerId']?.toString() ??
              item['createdBy']?.toString() ??
              companyMap['id']?.toString() ??
              companyMap['_id']?.toString() ??
              '',
          title: item['title']?.toString() ?? '',
          companyName: item['companyName']?.toString() ?? '',
          location: item['location']?.toString() ?? '',
          salaryRange: item['salaryRange']?.toString() ?? '',
          type: item['type']?.toString() ?? '',
          status: item['status']?.toString() ?? '',
          classification: item['classification']?.toString() ?? '',
          tags: item['tags'] is List ? List<String>.from(item['tags']) : [],
          publishedAt:
              DateTime.tryParse(item['createdAt']?.toString() ?? '') ??
              DateTime.now(),
          benefits: item['benefits'] is List
              ? List<String>.from(item['benefits'])
              : [],
          companyLogoUrl: item['companyLogoUrl'],
          companyIndustry: item['companyIndustry']?.toString(),
          capacity: int.tryParse(item['requiredCount']?.toString() ?? '1') ?? 1,
          acceptedCount:
              int.tryParse(item['acceptedCount']?.toString() ?? '0') ?? 0,
          viewsCount: int.tryParse(item['viewsCount']?.toString() ?? '0') ?? 0,
        ),
      );
    }
    _applications.clear();
    for (var item in applications) {
      _applications.add(
        RecruitmentApplication(
          id: item['id']?.toString() ?? '',
          jobId: item['jobId']?.toString() ?? '',
          jobTitle: item['jobTitle']?.toString() ?? '',
          companyName: item['companyName']?.toString() ?? '',
          userName: item['userName']?.toString() ?? '',
          status: item['status']?.toString() ?? '',
          updatedAt:
              DateTime.tryParse(item['updatedAt']?.toString() ?? '') ??
              DateTime.now(),
          gender: item['gender']?.toString(),
          birthDate: item['birthDate']?.toString() ?? item['dob']?.toString(),
          languages: item['languages'] is List
              ? List<String>.from(item['languages'])
              : const <String>[],
          about: item['about']?.toString(),
          experienceYears:
              int.tryParse(item['experienceYears']?.toString() ?? '0') ?? 0,
          education: item['education']?.toString(),
          skills: item['skills'] is List
              ? List<String>.from(item['skills'])
              : const <String>[],
          hasCv:
              item['hasCv'] == true ||
              (item['cvUrl']?.toString().trim().isNotEmpty ?? false),
          cvUrl: item['cvUrl']?.toString(),
          cvFileName: item['cvFileName']?.toString(),
          email: item['email']?.toString(),
          phone: item['phone']?.toString(),
          location: item['location']?.toString(),
        ),
      );
    }
    _messages.clear();
    for (var item in messages) {
      _messages.add(
        RecruitmentMessage(
          id: item['id']?.toString() ?? '',
          fromCompany: item['fromCompany'] == true,
          text: item['text']?.toString() ?? '',
          createdAt:
              DateTime.tryParse(item['createdAt']?.toString() ?? '') ??
              DateTime.now(),
        ),
      );
    }
    notifyListeners();
  }

  void companyPostJob(RecruitmentJob job) {
    _jobs.insert(0, job);
    notifyListeners();
  }

  void removeJob(String jobId) {
    _jobs.removeWhere((j) => j.id == jobId);
    notifyListeners();
  }

  void companyUpdateApplicationStatus({
    required String applicationId,
    required String nextStatus,
  }) {
    final idx = _applications.indexWhere((a) => a.id == applicationId);
    if (idx != -1) {
      _applications[idx] = _applications[idx].copyWith(
        status: nextStatus,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  void companySendMessage(String text) {
    _messages.insert(
      0,
      RecruitmentMessage(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        fromCompany: true,
        text: text,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void postServiceRequest({
    required String title,
    required String description,
    required String budget,
  }) {
    _serviceRequests.insert(
      0,
      ServiceRequestPost(
        id: 'sr_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        description: description,
        budget: budget,
        requestedBy: _currentUserName,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void userApplyToJob({required String jobId, required String userName}) {
    _applications.insert(
      0,
      RecruitmentApplication(
        id: 'app_${DateTime.now().millisecondsSinceEpoch}',
        jobId: jobId,
        jobTitle: 'Job',
        companyName: 'Company',
        userName: userName,
        status: 'Applied',
        updatedAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void clear() {
    _jobs.clear();
    _applications.clear();
    _messages.clear();
    _tradesmanChatThreads.clear();
    _savedJobIds.clear();
    _serviceRequests.clear();
    _currentUserName = 'User';
    _currentUserEmail = '';
    _currentUserPhone = '';
    _currentUserLocation = '';
    _currentUserAbout = '';
    _currentUserTitle = '';
    _currentUserGender = '';
    _currentUserIndustry = '';
    _userRole = 'Job Seeker';
    _profileImage = null;
    _searchQuery = '';
    _filterType = 'All';
    _filterLocation = 'All';
    _filterClassification = 'All';
    _filterSalaryRange = 'All';
    _currentUserSkills = [];
    _currentUserEducation = [];
    _currentUserExperience = [];
    _socialLinks = [];
    _portfolioImages = [];
    notifyListeners();
  }
}
