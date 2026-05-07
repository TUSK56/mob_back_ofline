final class JobBenefit {
  JobBenefit({required this.title, required this.description});
  final String title;
  final String description;

  Map<String, String> toMap() => {'title': title, 'description': description};
  factory JobBenefit.fromMap(Map<String, dynamic> map) => JobBenefit(
    title: map['title'] ?? '',
    description: map['description'] ?? '',
  );
}

/// The [Job] model represents a job posting created by a company.
/// It holds critical details used across the jobs hub and analytics screens.
final class Job {
  /// Constructs a new [Job] instance.
  Job({
    required this.id,
    required this.companyId,
    required this.title,
    required this.companyName,
    required this.location,
    required this.employmentType,
    required this.classification,
    required this.salaryRange,
    this.description = '',
    this.responsibilities = const [],
    this.niceToHaves = const [],
    this.qualifications = const [],
    this.benefits = const [],
    this.department = '',
    this.tags = const [],
    this.appliedCount = 0,
    this.requiredCount = 1,
    this.acceptedCount = 0,
    this.status = 'Open',
    this.viewsCount = 0,
    this.deadline,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String companyId;
  final String title;
  final String companyName;
  final String location;
  final String employmentType;
  final String classification;
  final String department;
  final String salaryRange;
  final String description;
  final List<String> responsibilities;
  final List<String> niceToHaves;
  final List<String> qualifications;
  final List<JobBenefit> benefits;
  final List<String> tags;
  final int appliedCount;
  final int requiredCount;
  final int acceptedCount;
  final String status;
  final int viewsCount;
  final DateTime? deadline;
  final DateTime createdAt;

  /// Gets the category (alias for classification for backward compatibility)
  String get category => classification;

  /// Creates a copy of the current [Job] while allowing specific fields to be updated.
  Job copyWith({
    String? id,
    String? companyId,
    String? title,
    String? companyName,
    String? location,
    String? employmentType,
    String? classification,
    String? department,
    String? salaryRange,
    String? description,
    List<String>? responsibilities,
    List<String>? niceToHaves,
    List<String>? qualifications,
    List<JobBenefit>? benefits,
    List<String>? tags,
    int? appliedCount,
    int? requiredCount,
    int? acceptedCount,
    String? status,
    int? viewsCount,
    DateTime? deadline,
    DateTime? createdAt,
  }) {
    return Job(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      title: title ?? this.title,
      companyName: companyName ?? this.companyName,
      location: location ?? this.location,
      employmentType: employmentType ?? this.employmentType,
      classification: classification ?? this.classification,
      department: department ?? this.department,
      salaryRange: salaryRange ?? this.salaryRange,
      description: description ?? this.description,
      responsibilities: responsibilities ?? this.responsibilities,
      niceToHaves: niceToHaves ?? this.niceToHaves,
      qualifications: qualifications ?? this.qualifications,
      benefits: benefits ?? this.benefits,
      tags: tags ?? this.tags,
      appliedCount: appliedCount ?? this.appliedCount,
      requiredCount: requiredCount ?? this.requiredCount,
      acceptedCount: acceptedCount ?? this.acceptedCount,
      status: status ?? this.status,
      viewsCount: viewsCount ?? this.viewsCount,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Generates a mock [Job] instance primarily for UI testing purposes.
  static Job mock() => Job(
    id: 'job_1',
    companyId: 'company_1',
    title: 'Social Media Assistant',
    companyName: 'Nomad',
    location: '',
    employmentType: 'Full-Time',
    classification: 'Technical',
    salaryRange: r'$15k-$85k USD',
    description:
        'Stripe is looking for Social Media Marketing expert to help manage our online networks.',
    responsibilities: [
      'Community engagement to ensure that we support and actively represented online',
      'Focus on social media content development and publication',
      'Marketing and strategy support',
    ],
    niceToHaves: [
      'Project management skills',
      'Copy editing skills',
      'Experience with online communities',
    ],
    tags: ['Marketing', 'Social Media', 'Content'],
    appliedCount: 5,
    requiredCount: 10,
    acceptedCount: 2,
  );

  static List<Job> mockList() => [];

  factory Job.fromMap(Map<String, dynamic> map) {
    return Job(
      id: map['id']?.toString() ?? '',
      companyId: map['companyId']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      companyName: map['companyName']?.toString() ?? '',
      location: map['location']?.toString() ?? '',
      employmentType: map['type']?.toString() ?? '',
      classification: map['classification']?.toString() ?? '',
      salaryRange: map['salaryRange']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      responsibilities: List<String>.from(map['responsibilities'] ?? []),
      qualifications: List<String>.from(map['qualifications'] ?? []),
      niceToHaves: List<String>.from(map['niceToHaves'] ?? []),
      benefits: (map['benefits'] as List<dynamic>?)?.map((e) {
        final raw = e.toString();
        if (raw.contains(':::')) {
          final parts = raw.split(':::');
          return JobBenefit(title: parts[0], description: parts[1]);
        }
        return JobBenefit(title: raw, description: '');
      }).toList() ?? [],
      tags: List<String>.from(map['tags'] ?? []),
      status: map['status']?.toString() ?? 'Open',
      requiredCount: int.tryParse(map['requiredCount']?.toString() ?? '1') ?? 1,
      acceptedCount: int.tryParse(map['acceptedCount']?.toString() ?? '0') ?? 0,
      viewsCount: int.tryParse(map['viewsCount']?.toString() ?? '0') ?? 0,
      deadline: map['deadline'] != null ? DateTime.tryParse(map['deadline'].toString()) : null,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt'].toString()) : null,
    );
  }
}
