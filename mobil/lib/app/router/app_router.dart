// Named routes ([AppRoutes]) and [AppRouter.onGenerateRoute] for the whole app.

import 'package:flutter/material.dart';

import '../../screens/company/auth/forgot_password_screen.dart';
import '../../screens/company/auth/otp_email_verification_screen.dart';
import '../../screens/company/auth/password_changed_dialog_screen.dart';
import '../../screens/company/auth/recruitment_company_sign_in_screen.dart';
import '../../screens/company/auth/reset_password_screen.dart';
import '../../screens/company/auth/sign_in_screen.dart';
import '../../screens/company/auth/sign_up_screen.dart';
import '../../screens/company/candidates/applicant_details_profile_screen.dart';
import '../../screens/company/candidates/applicant_details_resume_screen.dart';
import '../../screens/company/candidates/applicant_hiring_progress_hired_declined_screen.dart';
import '../../screens/company/candidates/recruitment_candidate_details_screen.dart';
import '../../screens/company/help/help_center_screen.dart';
import '../../screens/company/home/dashboard_screen.dart';
import '../../screens/company/jobs/job_analytics_screen.dart';

import '../../screens/company/jobs/job_applicants_table_view_screen.dart';
import '../../screens/company/jobs/job_details_screen.dart';
import '../../screens/company/jobs/jobs_hub_screen.dart';
import '../../screens/company/jobs/post_job/post_job_step1_information_screen.dart';
import '../../screens/company/jobs/post_job/post_job_step2_requirements_screen.dart';
import '../../screens/company/jobs/post_job/post_job_step3_benefits_screen.dart';
import '../../screens/company/jobs/recruitment_post_job_screen.dart';
import '../../screens/company/messages/chat_thread_candidate_v2_screen.dart';
import '../../screens/company/messages/chat_thread_screen.dart';
import '../../screens/company/messages/messages_list_screen.dart';
import '../../screens/company/messages/new_chat_screen.dart';
import '../../screens/company/onboarding/onboarding_future_starts_screen.dart';
import '../../screens/company/onboarding/onboarding_next_job_closer_screen.dart';
import '../../screens/company/onboarding/onboarding_smart_search_screen.dart';
import '../../screens/company/onboarding/recruitment_company_onboarding_screen.dart';
import '../../screens/company/profile/company_edit_intro_screen.dart';
import '../../screens/company/profile/company_profile_screen.dart';
import '../../screens/company/profile/profile_settings_overview_screen.dart';
import '../../screens/company/profile/profile_settings_social_links_screen.dart';
import '../../screens/company/profile/recruitment_company_profile_screen.dart';
import '../../screens/company/settings/account_security_screen.dart';
import '../../screens/company/settings/appearance_settings_dark_screen.dart';
import '../../screens/company/settings/appearance_settings_light_screen.dart';
import '../../screens/company/settings/notification_setting_screen.dart';
import '../../screens/company/settings/notifications_screen.dart';
import '../../screens/company/settings/settings_screen.dart';
import '../../screens/logo/logo_page.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/user/jobs/recruitment_application_timeline_screen.dart';
import '../../screens/user/jobs/recruitment_job_application_screen.dart';
import '../../screens/user/jobs/recruitment_job_filters_screen.dart';
import '../../screens/user/jobs/recruitment_job_details_screen.dart';
import '../../screens/user/auth/recruitment_user_sign_in_screen.dart';
import '../../screens/user/onboarding/onboarding.dart';
import '../../screens/user/onboarding/recruitment_user_onboarding_screen.dart';
import '../../screens/user/profile/edit_profile_screen.dart';
import '../../screens/user/settings/recruitment_user_settings_screen.dart';
import '../../screens/user/home/recruitment_user_shell_screen.dart';
import '../../screens/user/home/company_details_screen.dart';
import '../../shared/state/recruitment_sync_store.dart';
import '../../shared/models/applicant.dart';
import '../../shared/models/job.dart';
import '../../shared/models/message_thread.dart';

/// The [AppRoutes] class serves as a centralized registry for all named route string constants
/// used to navigate through the application. Using this class avoids hard-coded strings.
final class AppRoutes {
  /// Initial splash screen
  static const splash = '/';

  /// Role picker (User vs Company) shown after splash.
  static const roleSelection = '/role_selection';

  /// Job seeker onboarding ([OnBoardingScreen]) before auth.
  static const userOnboarding = '/user/onboarding';
  static const userWorkspace = '/user/workspace';
  static const userJobDetails = '/user/jobs/details';
  static const userJobApplication = '/user/jobs/apply';
  static const userAdvancedFilters = '/user/jobs/filters';
  static const userApplicationTimeline = '/user/jobs/application_timeline';
  static const userOnboardingNew = '/user/onboarding/new';
  static const userSettingsNew = '/user/settings/new';
  static const userSignInNew = '/user/auth/sign_in_new';
  static const userEditProfile = '/user/profile/edit';
  static const userCompanyDetails = '/user/company/details';

  // --- Company Onboarding Routes ---
  static const companyOnboardingSmartSearch =
      '/company/onboarding/smart_search';
  static const companyOnboardingNextJobCloser =
      '/company/onboarding/next_job_closer';
  static const companyOnboardingFutureStarts =
      '/company/onboarding/future_starts';

  // --- Company Authentication Routes ---
  static const companySignIn = '/company/auth/sign_in';
  static const companySignUp = '/company/auth/sign_up';
  static const companyForgotPassword = '/company/auth/forgot_password';
  static const companyOtp = '/company/auth/otp';
  static const companyResetPassword = '/company/auth/reset_password';
  static const companyPasswordChanged = '/company/auth/password_changed';

  // Company shell areas
  static const companyDashboard = '/company/home/dashboard';
  static const companyWorkspace = '/company/workspace';
  static const companyOnboardingNew = '/company/onboarding/new';
  static const companySignInNew = '/company/auth/sign_in_new';
  static const companyPostJobComposer = '/company/jobs/post_composer';
  static const companyProfileEditor = '/company/profile/editor';
  static const companyCandidateDetails = '/company/candidates/details_new';
  static const companyMessagesList = '/company/messages/list';
  static const companyChatThread = '/company/messages/thread';
  static const companyChatThreadCandidateV2 = '/company/messages/thread_v2';
  static const companyNewChat = '/company/messages/new_chat';

  static const companyJobsHub = '/company/jobs';
  static const companyApplicantsTable = '/company/jobs/applicants_table';
  static const companyApplicantsPipeline = '/company/jobs/applicants_pipeline';
  static const companyJobDetails = '/company/jobs/details';
  static const companyJobAnalytics = '/company/jobs/analytics';
  static const companyPostJobStep1 = '/company/jobs/post/step1';
  static const companyPostJobStep2 = '/company/jobs/post/step2';
  static const companyPostJobStep3 = '/company/jobs/post/step3';
  static const companyJobApplicants = '/company/job-applicants';

  static const companyApplicantDetailsProfile = '/company/candidates/profile';
  static const companyApplicantDetailsResume = '/company/candidates/resume';
  static const companyApplicantHiringHiredDeclined =
      '/company/candidates/hiring_hired_declined';

  static const companyProfileOverview = '/company/profile/overview';
  static const companyProfileSocialLinks = '/company/profile/social_links';
  static const companyCompanyProfile = '/company/profile/company_profile';
  static const companyEditIntro = '/company/profile/edit_intro';

  static const companySettings = '/company/settings';
  static const companyAppearanceDark = '/company/settings/appearance_dark';
  static const companyAppearanceLight = '/company/settings/appearance_light';
  static const companyNotificationSetting = '/company/settings/notification';
  static const companyNotifications = '/company/notifications';
  static const companyHelpCenter = '/company/help/center';
  static const companyAccountSecurity = '/company/settings/account_security';
}

/// The [AppRouter] is responsible for generating route transitions and providing
/// the requested screen widget mapped to [RouteSettings.name].
final class AppRouter {
  /// Resolves a named route to a [MaterialPageRoute] containing the requested screen.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final name = settings.name;
    final args = settings.arguments;
    final fallbackJob = RecruitmentSyncStore.instance.jobs.isNotEmpty
        ? RecruitmentSyncStore.instance.jobs.first
        : RecruitmentJob(
            id: 'fallback',
            companyId: 'fallback',
            title: 'No Job',
            companyName: 'Company',
            location: 'N/A',
            salaryRange: 'N/A',
            type: 'N/A',
            status: 'Open',
            tags: const <String>[],
            publishedAt: DateTime.now(),
            classification: 'N/A',
            benefits: const <String>[],
          );

    Widget page;
    switch (name) {
      case AppRoutes.splash:
        page = const SplashScreen();
      case AppRoutes.roleSelection:
        page = const LogoPage();
      case AppRoutes.userOnboarding:
        page = const OnBoardingScreen();
      case AppRoutes.userWorkspace:
        page = const RecruitmentUserShellScreen();
      case AppRoutes.userOnboardingNew:
        page = const RecruitmentUserOnboardingScreen();
      case AppRoutes.userJobDetails:
        page = RecruitmentJobDetailsScreen(
          job: args is RecruitmentJob ? args : fallbackJob,
        );
      case AppRoutes.userJobApplication:
        page = RecruitmentJobApplicationScreen(
          job: args is RecruitmentJob ? args : fallbackJob,
        );
      case AppRoutes.userAdvancedFilters:
        page = const RecruitmentJobFiltersScreen();
      case AppRoutes.userApplicationTimeline:
        final fallbackApplication =
            RecruitmentSyncStore.instance.applications.isNotEmpty
            ? RecruitmentSyncStore.instance.applications.first
            : RecruitmentApplication(
                id: 'fallback',
                jobId: 'fallback',
                jobTitle: 'Unknown',
                companyName: 'Unknown',
                userName: 'Unknown',
                status: 'Applied',
                updatedAt: DateTime.now(),
              );
        page = RecruitmentApplicationTimelineScreen(
          application: args is RecruitmentApplication
              ? args
              : fallbackApplication,
        );
      case AppRoutes.userSettingsNew:
        page = const RecruitmentUserSettingsScreen();
      case AppRoutes.userSignInNew:
        page = const RecruitmentUserSignInScreen();
      case AppRoutes.userEditProfile:
        page = const EditProfileScreen();
      case AppRoutes.userCompanyDetails:
        page = CompanyDetailsScreen(
          company: args is Map<String, dynamic> ? args : const {},
        );

      case AppRoutes.companyOnboardingSmartSearch:
        page = const CompanyOnboardingSmartSearchScreen();
      case AppRoutes.companyOnboardingNextJobCloser:
        page = const CompanyOnboardingNextJobCloserScreen();
      case AppRoutes.companyOnboardingFutureStarts:
        page = const CompanyOnboardingFutureStartsScreen();
      case AppRoutes.companySignIn:
        page = const CompanySignInScreen();
      case AppRoutes.companySignUp:
        page = const CompanySignUpScreen();
      case AppRoutes.companyForgotPassword:
        page = const CompanyForgotPasswordScreen();
      case AppRoutes.companyOtp:
        page = CompanyOtpEmailVerificationScreen(
          email: (args is String && args.isNotEmpty)
              ? args
              : 'example@mail.com',
        );
      case AppRoutes.companyResetPassword:
        page = const CompanyResetPasswordScreen();
      case AppRoutes.companyPasswordChanged:
        page = const CompanyPasswordChangedDialogScreen();
      case AppRoutes.companyDashboard:
        page = const CompanyDashboardScreen();
      case AppRoutes.companyWorkspace:
        // Legacy recruitment shell kept for reference; company workspace should use
        // the main company tabs (home/chat/job/profile/stats) via bottom nav.
        page = const CompanyDashboardScreen();
      case AppRoutes.companyOnboardingNew:
        page = const RecruitmentCompanyOnboardingScreen();
      case AppRoutes.companySignInNew:
        page = const RecruitmentCompanySignInScreen();
      case AppRoutes.companyPostJobComposer:
        page = const RecruitmentPostJobScreen();
      case AppRoutes.companyProfileEditor:
        page = const RecruitmentCompanyProfileScreen();
      case AppRoutes.companyCandidateDetails:
        final fallbackApplication =
            RecruitmentSyncStore.instance.applications.isNotEmpty
            ? RecruitmentSyncStore.instance.applications.first
            : RecruitmentApplication(
                id: 'fallback',
                jobId: 'fallback',
                jobTitle: 'Unknown',
                companyName: 'Unknown',
                userName: 'Unknown',
                status: 'Applied',
                updatedAt: DateTime.now(),
              );
        page = RecruitmentCandidateDetailsScreen(
          application: args is RecruitmentApplication
              ? args
              : fallbackApplication,
        );
      case AppRoutes.companyMessagesList:
        page = const CompanyMessagesListScreen();
      case AppRoutes.companyChatThread:
        page = CompanyChatThreadScreen(
          thread: args is MessageThread ? args : MessageThread.mock(),
        );
      case AppRoutes.companyChatThreadCandidateV2:
        page = CompanyChatThreadCandidateV2Screen(
          thread: args is MessageThread ? args : MessageThread.mock(),
        );
      case AppRoutes.companyNewChat:
        page = const CompanyNewChatScreen();
      case AppRoutes.companyJobsHub:
        page = const CompanyJobsHubScreen();
      case AppRoutes.companyApplicantsTable:
        final emptyJob = Job(
          id: '',
          companyId: '',
          title: '',
          companyName: '',
          location: '',
          employmentType: '',
          classification: '',
          salaryRange: '',
        );
        page = CompanyJobApplicantsTableViewScreen(
          job: args is Job ? args : emptyJob,
        );
      case AppRoutes.companyJobDetails:
        final emptyJob = Job(
          id: '',
          companyId: '',
          title: '',
          companyName: '',
          location: '',
          employmentType: '',
          classification: '',
          salaryRange: '',
        );
        page = CompanyJobDetailsScreen(job: args is Job ? args : emptyJob);
      case AppRoutes.companyJobAnalytics:
        final emptyJob = Job(
          id: '',
          companyId: '',
          title: '',
          companyName: '',
          location: '',
          employmentType: '',
          classification: '',
          salaryRange: '',
        );
        page = CompanyJobAnalyticsScreen(job: args is Job ? args : emptyJob);
      case AppRoutes.companyPostJobStep1:
        page = const CompanyPostJobStep1InformationScreen();
      case AppRoutes.companyPostJobStep2:
        page = const CompanyPostJobStep2DescriptionScreen();
      case AppRoutes.companyPostJobStep3:
        page = const CompanyPostJobStep3BenefitsScreen();
      case AppRoutes.companyJobApplicants:
        final emptyJob = Job(
          id: '',
          companyId: '',
          title: '',
          companyName: '',
          location: '',
          employmentType: '',
          classification: '',
          salaryRange: '',
        );
        page = CompanyJobApplicantsTableViewScreen(
          job: args is Job ? args : emptyJob,
        );
      case AppRoutes.companyApplicantDetailsProfile:
        page = CompanyApplicantDetailsProfileScreen(
          applicant: args is Applicant ? args : Applicant.mock(),
        );
      case AppRoutes.companyApplicantDetailsResume:
        page = CompanyApplicantDetailsResumeScreen(
          applicant: args is Applicant ? args : Applicant.mock(),
        );
      case AppRoutes.companyApplicantHiringHiredDeclined:
        page = CompanyApplicantHiringProgressHiredDeclinedScreen(
          applicant: args is Applicant ? args : Applicant.mock(),
        );
      case AppRoutes.companyProfileOverview:
        page = const CompanyProfileSettingsOverviewScreen();
      case AppRoutes.companyProfileSocialLinks:
        page = const CompanyProfileSettingsSocialLinksScreen();
      case AppRoutes.companyCompanyProfile:
        page = const CompanyCompanyProfileScreen();
      case AppRoutes.companyEditIntro:
        final intro = args is CompanyEditIntroArgs ? args : null;
        page = CompanyEditIntroScreen(
          initialEnglish: intro?.english ?? '',
          initialArabic: intro?.arabic ?? '',
        );
      case AppRoutes.companySettings:
        page = const CompanySettingsScreen();
      case AppRoutes.companyAppearanceDark:
        page = const CompanyAppearanceSettingsDarkScreen();
      case AppRoutes.companyAppearanceLight:
        page = const CompanyAppearanceSettingsLightScreen();
      case AppRoutes.companyNotificationSetting:
        page = const CompanyNotificationSettingScreen();
      case AppRoutes.companyNotifications:
        page = const CompanyNotificationsScreen();
      case AppRoutes.companyHelpCenter:
        page = const CompanyHelpCenterScreen();
      case AppRoutes.companyAccountSecurity:
        page = const CompanyAccountSecurityScreen();
      default:
        page = const _UnknownRouteScreen();
    }

    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}

class _UnknownRouteScreen extends StatelessWidget {
  const _UnknownRouteScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unknown route')),
      body: Center(
        child: Text(
          'Route not found: ${ModalRoute.of(context)?.settings.name}',
        ),
      ),
    );
  }
}
