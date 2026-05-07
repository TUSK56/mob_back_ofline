import 'api_endpoints.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

final class CompanyApiClient {
  CompanyApiClient({String? baseUrl})
    : baseUrl = baseUrl ?? ApiEndpoints.baseUrl,
      _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl ?? ApiEndpoints.baseUrl,
          connectTimeout: const Duration(seconds: 12),
          receiveTimeout: const Duration(seconds: 12),
          headers: const {'Content-Type': 'application/json'},
        ),
      ) {
    debugPrint('[CompanyApiClient] baseUrl=$baseUrl');
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (o) => debugPrint(o.toString()),
      ),
    );
  }

  final String baseUrl;
  final Dio _dio;
  String? _accessToken;
  bool get hasToken => _accessToken != null && _accessToken!.isNotEmpty;

  void setToken(String token) {
    _accessToken = token;
  }

  void clearToken() {
    _accessToken = null;
  }

  Options get _authOptions => Options(
    headers: _accessToken == null
        ? null
        : <String, dynamic>{'Authorization': 'Bearer $_accessToken'},
  );

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    String? role,
  }) async {
    final payload = <String, dynamic>{'email': email, 'password': password};
    if (role != null && role.trim().isNotEmpty) {
      payload['role'] = role.trim().toLowerCase();
    }
    final Response<dynamic> response = await _dio.post<dynamic>(
      ApiEndpoints.login,
      data: payload,
    );
    return Map<String, dynamic>.from(response.data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> googleLogin({required String idToken}) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      ApiEndpoints.googleLogin,
      data: <String, dynamic>{'idToken': idToken},
    );
    return Map<String, dynamic>.from(response.data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      ApiEndpoints.register,
      data: <String, dynamic>{
        'email': email,
        'password': password,
        'name': name,
        'role': role,
      },
    );
    return Map<String, dynamic>.from(response.data as Map<String, dynamic>);
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
    final Response<dynamic> response = await _dio.put<dynamic>(
      ApiEndpoints.profile,
      data: <String, dynamic>{
        if (name != null) 'name': name,
        if (photoUrl != null) 'photoUrl': photoUrl,
        if (about != null) 'about': about,
        if (staff != null) 'staff': staff,
        if (industry != null) 'industry': industry,
        if (location != null) 'location': location,
        if (website != null) 'website': website,
        if (locations != null) 'locations': locations,
        if (techStack != null) 'techStack': techStack,
        if (benefits != null) 'benefits': benefits,
        if (classification != null) 'classification': classification,
        if (foundedDay != null) 'foundedDay': foundedDay,
        if (foundedMonth != null) 'foundedMonth': foundedMonth,
        if (foundedYear != null) 'foundedYear': foundedYear,
        if (phone != null) 'phone': phone,
        if (gender != null) 'gender': gender,
        if (dob != null) 'dob': dob,
        if (address != null) 'address': address,
        if (title != null) 'title': title,
        if (skills != null) 'skills': skills,
        if (educationJson != null) 'educationJson': educationJson,
        if (experienceJson != null) 'experienceJson': experienceJson,
        if (socialLinksJson != null) 'socialLinksJson': socialLinksJson,
        if (portfolioImagesJson != null) 'portfolioImagesJson': portfolioImagesJson,
      },
      options: _authOptions,
    );
    return Map<String, dynamic>.from(response.data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> fetchProfile() async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      ApiEndpoints.profile,
      options: _authOptions,
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<List<Map<String, dynamic>>> fetchJobs() async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      ApiEndpoints.jobs,
      options: _authOptions,
    );
    return (response.data as List<dynamic>)
      .map((dynamic e) => Map<String, dynamic>.from(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Map<String, dynamic>>> fetchApplications() async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      ApiEndpoints.applications,
      options: _authOptions,
    );
    return (response.data as List<dynamic>)
      .map((dynamic e) => Map<String, dynamic>.from(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> createJob({
    required String title,
    required String companyName,
    required String location,
    required String salaryRange,
    required String type,
    required String description,
    required List<String> responsibilities,
    required List<String> qualifications,
    required List<String> niceToHaves,
    required List<String> benefits,
    required List<String> tags,
    required String classification,
    int requiredCount = 1,
    DateTime? deadline,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      ApiEndpoints.jobs,
      data: <String, dynamic>{
        'title': title,
        'companyName': companyName,
        'location': location,
        'salaryRange': salaryRange,
        'type': type,
        'description': description,
        'responsibilities': responsibilities,
        'qualifications': qualifications,
        'niceToHaves': niceToHaves,
        'benefits': benefits,
        'tags': tags,
        'classification': classification,
        'requiredCount': requiredCount,
        if (deadline != null) 'deadline': deadline.toIso8601String(),
      },
      options: _authOptions,
    );
    return Map<String, dynamic>.from(response.data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> updateJob({
    required String jobId,
    required String title,
    required String companyName,
    required String location,
    required String salaryRange,
    required String type,
    required String description,
    required List<String> responsibilities,
    required List<String> qualifications,
    required List<String> niceToHaves,
    required List<String> benefits,
    required String classification,
    required List<String> tags,
    required int requiredCount,
    DateTime? deadline,
    String? status,
  }) async {
    final payload = <String, dynamic>{
      'title': title,
      'companyName': companyName,
      'location': location,
      'salaryRange': salaryRange,
      'type': type,
      'description': description,
      'responsibilities': responsibilities,
      'qualifications': qualifications,
      'niceToHaves': niceToHaves,
      'benefits': benefits,
      'classification': classification,
      'tags': tags,
      'requiredCount': requiredCount,
      if (deadline != null) 'deadline': deadline.toUtc().toIso8601String(),
      if (status != null) 'status': status,
    };

    final res = await _dio.put<dynamic>(
      '${ApiEndpoints.jobs}/$jobId',
      data: payload,
      options: _authOptions,
    );
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createApplication({
    required String jobId,
    required String userName,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      ApiEndpoints.applications,
      data: <String, dynamic>{'jobId': jobId, 'userName': userName},
      options: _authOptions,
    );
    return Map<String, dynamic>.from(response.data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> updateApplicationStatus({
    required String applicationId,
    required String status,
  }) async {
    final String path = ApiEndpoints.applicationStatus.replaceFirst(
      '{id}',
      applicationId,
    );
    final Response<dynamic> response = await _dio.patch<dynamic>(
      path,
      data: <String, dynamic>{'status': status},
      options: _authOptions,
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<List<Map<String, dynamic>>> fetchMessages() async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      ApiEndpoints.messages,
      options: _authOptions,
    );
    return (response.data as List<dynamic>)
      .map((dynamic e) => Map<String, dynamic>.from(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> sendMessage(String text) async {
    await _dio.post<dynamic>(
      ApiEndpoints.messages,
      data: <String, dynamic>{'text': text},
      options: _authOptions,
    );
  }

  Future<void> deleteJob(String jobId) async {
    await _dio.delete<dynamic>(
      '${ApiEndpoints.jobs}/$jobId',
      options: _authOptions,
    );
  }
}
