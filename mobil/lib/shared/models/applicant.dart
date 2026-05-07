/// The [Applicant] model contains details about a candidate moving through
/// the hiring pipeline stages (e.g. In Review, Interview, Hired).
final class Applicant {
  /// Constructs a new [Applicant] instance.
  Applicant({
    required this.id,
    required this.fullName,
    required this.role,
    required this.rating,
    required this.stage,
    required this.email,
    required this.phone,
    required this.location,
    required this.appliedDateLabel,
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
    required this.jobId,
  });

  final String id;
  final String fullName;
  final String role;
  final double rating;
  final String stage;
  final String email;
  final String phone;
  final String location;
  final String appliedDateLabel;

  // Additional fields from screenshot
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
  final String jobId;

  /// Generates a static mock [Applicant] to populate the UI templates.
  static Applicant mock() => Applicant(
        id: 'app_1',
        fullName: 'Dragon',
        role: 'متخصص',
        rating: 4.5,
        stage: 'In Review',
        email: 'mahmoudessam936@gmail.com',
        phone: '+20 123 456 789',
        location: 'غير محدد',
        appliedDateLabel: 'Today',
        gender: 'لم يحدد',
        birthDate: 'غير متوفر',
        languages: ['العربية'],
        about: 'لا يوجد نبذة تعريفية متاحة لهذا المتقدم.',
        experienceYears: 0,
        education: 'غير متوفر',
        skills: [],
        hasCv: false,
        cvUrl: null,
        cvFileName: null,
        jobId: 'job_1',
      );

  static List<Applicant> mockList() => [];
}

