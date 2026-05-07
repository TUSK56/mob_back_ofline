import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../../data/api/company_api_client.dart';
import '../state/company_store.dart';
import '../state/recruitment_sync_store.dart';
import '../models/job.dart';
import 'session_manager.dart';

class RecruitmentSyncService {
  RecruitmentSyncService._();

  static final RecruitmentSyncService instance = RecruitmentSyncService._();

  final CompanyApiClient _client = CompanyApiClient();
  Timer? _timer;
  bool get isAuthenticated => _client.hasToken;

  void setTokenManually(String token) {
    _client.setToken(token);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String expectedRole,
  }) async {
    final auth = await _client.login(
      email: email.trim(),
      password: password,
      role: expectedRole,
    );

    final user = auth['user'] as Map<String, dynamic>?;
    final role = user?['role']?.toString().toLowerCase().trim();
    final token = auth['token']?.toString().trim();
    final expected = expectedRole.toLowerCase().trim();

    if (token == null || token.isEmpty) {
      throw Exception('Login response missing token');
    }
    if (role == null || role.isEmpty) {
      throw Exception('Login response missing role');
    }
    if (expected == 'company') {
      if (role != 'company') {
        throw Exception('هذا الحساب ليس حساب شركة');
      }
    } else {
      // For user login, block company accounts from signing in
      if (role == 'company') {
        throw Exception('هذا الحساب مخصص للشركات');
      }
    }

    await _handleLoginSuccess(user, token, email, role);
    return user ?? {};
  }

  Future<void> _handleLoginSuccess(
    Map<String, dynamic>? user,
    String? token,
    String email,
    String role,
  ) async {
    if (user == null || token == null || token.isEmpty) return;

    _client.setToken(token);
    await SessionManager.saveToken(token);

    final String name = user['name']?.toString() ?? 'User';
    final String userId =
        user['id']?.toString() ??
        user['_id']?.toString() ??
        user['userId']?.toString() ??
        '';
    _syncUserFromResponse(user);

    if (role.toLowerCase().trim() == 'company') {
      await SessionManager.saveCompanySession(
        email: email,
        name: name,
        id: userId,
      );
      CompanyStore.instance.setRegistrationData(
        companyId: userId,
        companyName: name,
        email: email,
      );
      try {
        await _pullProfileFromServer();
      } catch (_) {}
    } else {
      await SessionManager.saveUserSession(email: email, name: name);
      await _pullProfileFromServer();
    }
  }

  Future<Map<String, dynamic>> googleLogin(String idToken) async {
    final auth = await _client.googleLogin(idToken: idToken);

    final user = auth['user'] as Map<String, dynamic>?;
    final token = auth['token']?.toString().trim();

    if (token == null || token.isEmpty) {
      throw Exception('Google login response missing token');
    }

    await _handleLoginSuccess(
      user,
      token,
      user?['email']?.toString() ?? '',
      user?['role']?.toString() ?? '',
    );
    return user ?? {};
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    final auth = await _client.register(
      email: email.trim(),
      password: password,
      name: name.trim(),
      role: role.toLowerCase().trim(),
    );

    final user = auth['user'] as Map<String, dynamic>?;
    final token = auth['token']?.toString().trim();

    if (token == null || token.isEmpty) {
      throw Exception('Registration response missing token');
    }

    await _handleLoginSuccess(user, token, email, role);
    return user ?? {};
  }

  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? photoUrl,
    String? about,
    String? staff,
    String? industry,
    String? location,
    String? website,
    List<String>? locations,
    List<String>? techStack,
    List<String>? benefits,
    String? classification,
    int? foundedDay,
    int? foundedMonth,
    int? foundedYear,
    String? phone,
    String? gender,
    String? dob,
    String? address,
    String? title,
    List<String>? skills,
    String? educationJson,
    String? experienceJson,
    String? socialLinksJson,
    String? portfolioImagesJson,
  }) async {
    await _ensureAuthenticated();
    final user = await _client.updateProfile(
      name: name,
      photoUrl: photoUrl,
      about: about,
      staff: staff,
      industry: industry,
      location: location,
      website: website,
      locations: locations,
      techStack: techStack,
      benefits: benefits,
      classification: classification,
      foundedDay: foundedDay,
      foundedMonth: foundedMonth,
      foundedYear: foundedYear,
      phone: phone,
      gender: gender,
      dob: dob,
      address: address,
      title: title,
      skills: skills,
      educationJson: educationJson,
      experienceJson: experienceJson,
      socialLinksJson: socialLinksJson,
      portfolioImagesJson: portfolioImagesJson,
    );

    _syncUserFromResponse(user, photoUrl: photoUrl);

    if (RecruitmentSyncStore.instance.userRole.toLowerCase() == 'company') {
      final String currentName = user['name']?.toString() ?? 'User';
      final apiPhoto = user['photoUrl']?.toString().trim();
      final String? effectivePhoto = (apiPhoto != null && apiPhoto.isNotEmpty)
          ? apiPhoto
          : photoUrl;

      CompanyStore.instance.setRegistrationData(
        companyName: currentName,
        customProfileImage:
            (effectivePhoto != null && effectivePhoto.isNotEmpty)
            ? effectivePhoto
            : null,
      );
    }

    return user;
  }

  void _syncUserFromResponse(Map<String, dynamic> user, {String? photoUrl}) {
    final String currentName = user['name']?.toString() ?? 'User';
    final apiPhoto = user['photoUrl']?.toString().trim();
    final String? effectivePhoto = (apiPhoto != null && apiPhoto.isNotEmpty)
        ? apiPhoto
        : photoUrl;

    RecruitmentSyncStore.instance.updateCurrentUser(
      name: currentName,
      email: user['email']?.toString(),
      phone: user['phone']?.toString(),
      location: user['location']?.toString(),
      photoUrl: (effectivePhoto != null && effectivePhoto.isNotEmpty)
          ? effectivePhoto
          : null,
    );
    RecruitmentSyncStore.instance.updateUserProfile(
      fullName: currentName,
      title:
          user['title']?.toString() ??
          RecruitmentSyncStore.instance.currentUserTitle,
      email: user['email']?.toString(),
      phone: user['phone']?.toString(),
      location: user['address']?.toString() ?? user['location']?.toString(),
      about: user['about']?.toString(),
      industry: user['industry']?.toString(),
      gender: user['gender']?.toString(),
      role: user['role']?.toString() ?? RecruitmentSyncStore.instance.userRole,
      skills: user['skills'] is List ? List<String>.from(user['skills']) : null,
      education: _decodeMapList(user['educationJson']?.toString()),
      experience: _decodeMapList(user['experienceJson']?.toString()),
      socialLinks: _decodeMapList(user['socialLinksJson']?.toString()),
      portfolioImages: user['portfolioImagesJson'] != null
          ? List<String>.from(
              jsonDecode(user['portfolioImagesJson']?.toString() ?? '[]'),
            )
          : null,
    );

    if (RecruitmentSyncStore.instance.userRole.toLowerCase() == 'company') {
      CompanyStore.instance.syncFromMap(user);
    }
  }

  Future<void> _pullProfileFromServer() async {
    try {
      await _ensureAuthenticated();
      final user = await _client.fetchProfile();
      _syncUserFromResponse(user);
    } catch (e) {
      // Keep backward compatibility with backends that don't expose GET profile.
      try {
        final user = await _client.updateProfile();
        _syncUserFromResponse(user);
      } catch (_) {}
    }
  }

  Future<void> logout() async {
    _client.clearToken();
    stopPolling();
    RecruitmentSyncStore.instance.clear();
    CompanyStore.instance.clear();
    await SessionManager.logoutCompany();
    await SessionManager.logoutUser();
  }

  Future<void> _ensureAuthenticated() async {
    await _hydrateTokenFromSession();
    if (!isAuthenticated) {
      throw Exception('Not authenticated. Please login first.');
    }
  }

  Future<void> _hydrateTokenFromSession() async {
    if (_client.hasToken) return;
    final token = await SessionManager.getToken();
    if (token != null && token.isNotEmpty) {
      _client.setToken(token);
    }
  }

  Future<void> loginForDemo({required bool companyRole}) async {
    await login(
      email: companyRole ? 'company@jobito.com' : 'user@jobito.com',
      password: '12345678',
      expectedRole: companyRole ? 'company' : 'user',
    );
  }

  Future<void> startPolling() async {
    await _hydrateUserStateFromSession();
    try {
      await CompanyStore.instance.initFromSession();
    } catch (_) {}
    await _pullProfileFromServer();
    await _pullServerState();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 12), (_) async {
      await _pullServerState();
    });
  }

  void stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _pullServerState() async {
    final RecruitmentSyncStore store = RecruitmentSyncStore.instance;
    try {
      await _ensureAuthenticated();
      await _pullProfileFromServer();
      final jobs = await _client.fetchJobs();
      final applications = await _client.fetchApplications();
      final messages = await _client.fetchMessages();
      store.replaceFromRemote(
        jobs: jobs,
        applications: applications,
        messages: messages,
      );

      // Also sync CompanyStore jobs if the user is a company.
      // Strictly filter by companyId — never fall back to showing all jobs.
      if (store.userRole.toLowerCase() == 'company') {
        final String companyId = CompanyStore.instance.companyId;
        CompanyStore.instance.clearJobs();
        if (companyId.trim().isNotEmpty) {
          final myJobs = jobs
              .where((j) => _isMyCompanyJob(j, companyId))
              .toList();
          for (final j in myJobs) {
            CompanyStore.instance.saveJob(Job.fromMap(j));
          }
        }
      }
    } catch (e) {
      if (_isUnauthorizedError(e)) {
        // Do not destroy local session on polling 401.
        // Some endpoints can return unauthorized based on role/permission state.
        // We simply stop polling and keep the user signed in.
        stopPolling();
        return;
      }
      // Keep local state if backend is unreachable.
    }
  }

  Future<String> postJob({
    required String title,
    required String location,
    required String salaryRange,
    required String description,
    required List<String> responsibilities,
    required List<String> qualifications,
    required List<String> niceToHaves,
    required List<String> benefits,
    required String classification,
    String companyName = 'Jobito Labs',
    String type = 'Full-time',
    List<String> tags = const <String>['General'],
    int requiredCount = 1,
    DateTime? deadline,
  }) async {
    await _ensureAuthenticated();
    final response = await _client.createJob(
      title: title,
      companyName: companyName,
      location: location,
      salaryRange: salaryRange,
      type: type,
      description: description,
      responsibilities: responsibilities,
      qualifications: qualifications,
      niceToHaves: niceToHaves,
      benefits: benefits,
      tags: tags,
      classification: classification,
      requiredCount: requiredCount,
      deadline: deadline,
    );
    final String jobId = response['id']?.toString() ?? '';
    await _pullServerState();
    return jobId;
  }

  Future<void> updateJob({
    required String jobId,
    required String title,
    required String location,
    required String salaryRange,
    required String description,
    required List<String> responsibilities,
    required List<String> qualifications,
    required List<String> niceToHaves,
    required List<String> benefits,
    required String classification,
    String companyName = 'Jobito Labs',
    String type = 'Full-time',
    List<String> tags = const <String>['General'],
    int requiredCount = 1,
    DateTime? deadline,
    String? status,
  }) async {
    await _ensureAuthenticated();
    await _client.updateJob(
      jobId: jobId,
      title: title,
      companyName: companyName,
      location: location,
      salaryRange: salaryRange,
      type: type,
      description: description,
      responsibilities: responsibilities,
      qualifications: qualifications,
      niceToHaves: niceToHaves,
      benefits: benefits,
      tags: tags,
      classification: classification,
      requiredCount: requiredCount,
      deadline: deadline,
      status: status,
    );
    await _pullServerState();
  }

  Future<void> applyToJob({
    required String jobId,
    required String userName,
  }) async {
    await _ensureAuthenticated();
    await _client.createApplication(jobId: jobId, userName: userName);
    await _pullServerState();
  }

  Future<void> updateStatus({
    required String applicationId,
    required String status,
  }) async {
    await _ensureAuthenticated();
    try {
      await _client.updateApplicationStatus(
        applicationId: applicationId,
        status: status,
      );
      if (status.toLowerCase().contains('hire')) {
        await _autoCloseFilledJobs();
      }
      await _pullServerState();
    } catch (e) {
      if (_isUnauthorizedError(e)) {
        await logout();
        rethrow;
      }
      RecruitmentSyncStore.instance.companyUpdateApplicationStatus(
        applicationId: applicationId,
        nextStatus: status,
      );
      if (status.toLowerCase().contains('hire')) {
        await _autoCloseFilledJobs();
      }
    }
  }

  Future<void> reopenJobAndResetAccepted(String jobId) async {
    await _ensureAuthenticated();
    final store = RecruitmentSyncStore.instance;
    RecruitmentJob? job;
    for (final item in store.jobs) {
      if (item.id == jobId) {
        job = item;
        break;
      }
    }
    if (job == null) return;

    final hiredApps = store.applications
        .where(
          (a) => a.jobId == jobId && a.status.toLowerCase().contains('hire'),
        )
        .toList();

    for (final app in hiredApps) {
      await _client.updateApplicationStatus(
        applicationId: app.id,
        status: 'Applied',
      );
    }

    await _client.updateJob(
      jobId: job.id,
      title: job.title,
      companyName: job.companyName,
      location: job.location,
      salaryRange: job.salaryRange,
      type: job.type,
      description: job.description,
      responsibilities: job.responsibilities,
      qualifications: job.qualifications,
      niceToHaves: job.niceToHaves,
      benefits: job.benefits,
      classification: job.classification,
      tags: job.tags,
      requiredCount: job.capacity,
      status: 'Open',
    );
    await _pullServerState();
  }

  Future<void> _autoCloseFilledJobs() async {
    final store = RecruitmentSyncStore.instance;
    final jobsById = <String, RecruitmentJob>{
      for (final job in store.jobs) job.id: job,
    };
    if (jobsById.isEmpty) return;

    final hiredCountByJob = <String, int>{};
    for (final app in store.applications) {
      if (!app.status.toLowerCase().contains('hire')) continue;
      hiredCountByJob.update(app.jobId, (value) => value + 1, ifAbsent: () => 1);
    }

    for (final entry in hiredCountByJob.entries) {
      final job = jobsById[entry.key];
      if (job == null) continue;
      if (job.status.toLowerCase() == 'closed') continue;
      final requiredCount = job.capacity > 0 ? job.capacity : 1;
      if (entry.value < requiredCount) continue;

      await _client.updateJob(
        jobId: job.id,
        title: job.title,
        companyName: job.companyName,
        location: job.location,
        salaryRange: job.salaryRange,
        type: job.type,
        description: job.description,
        responsibilities: job.responsibilities,
        qualifications: job.qualifications,
        niceToHaves: job.niceToHaves,
        benefits: job.benefits,
        classification: job.classification,
        tags: job.tags,
        requiredCount: job.capacity,
        status: 'Closed',
      );
    }
  }

  Future<void> sendBroadcast(String text) async {
    await _ensureAuthenticated();
    try {
      await _client.sendMessage(text);
      await _pullServerState();
    } catch (e) {
      if (_isUnauthorizedError(e)) {
        await logout();
        rethrow;
      }
      RecruitmentSyncStore.instance.companySendMessage(text);
    }
  }

  Future<void> deleteJob(String jobId) async {
    await _ensureAuthenticated();
    await _client.deleteJob(jobId);
    // Optimistically remove from both local stores before server refresh
    RecruitmentSyncStore.instance.removeJob(jobId);
    CompanyStore.instance.deleteJob(jobId);
    await _pullServerState();
  }

  bool _isUnauthorizedError(Object error) {
    if (error is DioException) {
      return error.response?.statusCode == 401;
    }
    final text = error.toString();
    return text.contains('status code of 401') ||
        text.contains('status code 401');
  }

  Future<void> _hydrateUserStateFromSession() async {
    final data = await SessionManager.getUserData();
    final full = await SessionManager.getUserFullProfile();

    final String name = data['name']?.toString() ?? '';
    final String email = data['email']?.toString() ?? '';
    final String? photo = data['photo']?.toString();
    final String role =
        full['role']?.toString() ?? RecruitmentSyncStore.instance.userRole;
    final String title =
        full['title']?.toString() ??
        RecruitmentSyncStore.instance.currentUserTitle;

    if (name.isEmpty &&
        email.isEmpty &&
        (photo == null || photo.isEmpty) &&
        title.isEmpty) {
      return;
    }

    RecruitmentSyncStore.instance.updateCurrentUser(
      name: name.isEmpty ? RecruitmentSyncStore.instance.currentUserName : name,
      email: email.isEmpty
          ? RecruitmentSyncStore.instance.currentUserEmail
          : email,
      phone: full['phone']?.toString(),
      location: full['location']?.toString(),
      photoUrl: (photo != null && photo.isNotEmpty) ? photo : null,
    );
    RecruitmentSyncStore.instance.updateUserProfile(
      fullName: name.isEmpty
          ? RecruitmentSyncStore.instance.currentUserName
          : name,
      title: title,
      about: full['about']?.toString(),
      role: role,
      skills: List<String>.from(
        full['skills'] as List<dynamic>? ?? const <String>[],
      ),
      education: _decodeMapList(full['education']?.toString()),
      experience: _decodeMapList(full['experience']?.toString()),
      socialLinks: _decodeMapList(full['socialLinks']?.toString()),
      portfolioImages: List<String>.from(
        full['portfolioImages'] as List<dynamic>? ?? const <String>[],
      ),
    );
  }

  List<Map<String, String>> _decodeMapList(String? jsonValue) {
    if (jsonValue == null || jsonValue.trim().isEmpty) {
      return <Map<String, String>>[];
    }
    try {
      final dynamic decoded = jsonDecode(jsonValue);
      if (decoded is List) {
        return decoded
            .map(
              (dynamic item) => Map<String, String>.from(
                (item as Map).map(
                  (key, value) =>
                      MapEntry(key.toString(), value?.toString() ?? ''),
                ),
              ),
            )
            .toList();
      }
    } catch (_) {}
    return <Map<String, String>>[];
  }

  bool _isMyCompanyJob(Map<String, dynamic> job, String companyId) {
    if (companyId.trim().isEmpty) return false;
    final candidates = <String>[
      job['companyId']?.toString() ?? '',
      job['company_id']?.toString() ?? '',
      job['ownerId']?.toString() ?? '',
      job['userId']?.toString() ?? '',
      job['createdBy']?.toString() ?? '',
      (job['company'] is Map)
          ? (job['company']['id']?.toString() ??
                job['company']['_id']?.toString() ??
                '')
          : '',
    ];
    return candidates.any((value) => value.trim() == companyId.trim());
  }
}
