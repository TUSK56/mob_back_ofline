// Simple AR/EN strings and [LocalizationsDelegate] (no codegen).

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  AppLocalizations(
    this.locale, {
    Map<String, dynamic>? userStrings,
    Map<String, dynamic>? companyStrings,
  }) : _userStrings = userStrings ?? const <String, dynamic>{},
       _companyStrings = companyStrings ?? const <String, dynamic>{};

  final Locale locale;
  final Map<String, dynamic> _userStrings;
  final Map<String, dynamic> _companyStrings;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final l = Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(l != null, 'AppLocalizations not found in context');
    return l!;
  }

  bool get isAr => locale.languageCode.toLowerCase().startsWith('ar');

  String tr({required String en, required String ar}) => isAr ? ar : en;

  String userTr(
    String key, {
    required String fallbackEn,
    required String fallbackAr,
  }) {
    final value = _userStrings[key];
    if (value is String && value.isNotEmpty) return value;
    return isAr ? fallbackAr : fallbackEn;
  }

  String companyTr(
    String key, {
    required String fallbackEn,
    required String fallbackAr,
  }) {
    final value = _companyStrings[key];
    if (value is String && value.isNotEmpty) return value;
    return isAr ? fallbackAr : fallbackEn;
  }

  // ── Bottom Nav ─────────────────────────────────────────────────────────────
  String get home =>
      userTr('common.home', fallbackEn: 'Home', fallbackAr: 'الرئيسية');
  String get chat =>
      userTr('common.chat', fallbackEn: 'Chat', fallbackAr: 'المحادثة');
  String get job =>
      userTr('common.job', fallbackEn: 'Job', fallbackAr: 'الوظائف');
  String get profile => userTr(
    'common.profile',
    fallbackEn: 'Profile',
    fallbackAr: 'الملف الشخصي',
  );
  String get stats =>
      userTr('common.stats', fallbackEn: 'Stats', fallbackAr: 'الإحصائيات');
  String get preferences => userTr(
    'common.preferences',
    fallbackEn: 'Preferences',
    fallbackAr: 'التفضيلات',
  );
  String get systemMode =>
      userTr('common.systemMode', fallbackEn: 'System', fallbackAr: 'النظام');

  // ── Language / Settings ────────────────────────────────────────────────────
  String get language =>
      userTr('common.language', fallbackEn: 'Language', fallbackAr: 'اللغة');
  String get arabic =>
      userTr('common.arabic', fallbackEn: 'Arabic', fallbackAr: 'العربية');
  String get english =>
      userTr('common.english', fallbackEn: 'English', fallbackAr: 'English');
  String get appearance => userTr(
    'common.appearance',
    fallbackEn: 'Appearance',
    fallbackAr: 'المظهر',
  );
  String get theme =>
      userTr('common.theme', fallbackEn: 'Theme', fallbackAr: 'المظهر العام');
  String get dark =>
      userTr('common.dark', fallbackEn: 'Dark', fallbackAr: 'داكن');
  String get light =>
      userTr('common.light', fallbackEn: 'Light', fallbackAr: 'فاتح');
  String get settings => userTr(
    'common.settings',
    fallbackEn: 'Settings',
    fallbackAr: 'الإعدادات',
  );
  String get notifications => userTr(
    'common.notifications',
    fallbackEn: 'Notifications',
    fallbackAr: 'الإشعارات',
  );

  // ── Common actions ─────────────────────────────────────────────────────────
  String get continueBtn =>
      userTr('common.continue', fallbackEn: 'Continue', fallbackAr: 'متابعة');
  String get next =>
      userTr('common.next', fallbackEn: 'Next', fallbackAr: 'التالي');
  String get nextStep => userTr(
    'common.nextStep',
    fallbackEn: 'Next Step',
    fallbackAr: 'الخطوة التالية',
  );
  String get getStarted => userTr(
    'common.getStarted',
    fallbackEn: 'Get Started',
    fallbackAr: 'ابدأ الآن',
  );
  String get save =>
      userTr('common.save', fallbackEn: 'Save', fallbackAr: 'حفظ');
  String get saveChange => userTr(
    'common.saveChange',
    fallbackEn: 'Save Change',
    fallbackAr: 'حفظ التغييرات',
  );
  String get saved =>
      userTr('common.saved', fallbackEn: 'Saved', fallbackAr: 'تم الحفظ');
  String get cancel =>
      userTr('common.cancel', fallbackEn: 'Cancel', fallbackAr: 'إلغاء');
  String get delete =>
      userTr('common.delete', fallbackEn: 'Delete', fallbackAr: 'حذف');
  String get edit =>
      userTr('common.edit', fallbackEn: 'Edit', fallbackAr: 'تعديل');
  String get addMore => userTr(
    'common.addMore',
    fallbackEn: 'Add more',
    fallbackAr: 'إضافة المزيد',
  );
  String get reply =>
      userTr('common.reply', fallbackEn: 'Reply', fallbackAr: 'رد');
  String get yes => userTr('common.yes', fallbackEn: 'Yes', fallbackAr: 'نعم');
  String get no => userTr('common.no', fallbackEn: 'No', fallbackAr: 'لا');
  String get upload =>
      userTr('common.upload', fallbackEn: 'Upload', fallbackAr: 'رفع');
  String get required =>
      userTr('common.required', fallbackEn: 'Required', fallbackAr: 'مطلوب');
  String get notYet =>
      userTr('common.notYet', fallbackEn: 'not yet', fallbackAr: 'ليس بعد');

  // ── Validation ─────────────────────────────────────────────────────────────
  String get enterValidEmail => userTr(
    'validation.enterValidEmail',
    fallbackEn: 'Enter a valid email',
    fallbackAr: 'أدخل بريدًا إلكترونيًا صحيحًا',
  );
  String get min8Chars => userTr(
    'validation.min8Chars',
    fallbackEn: 'Minimum 8 characters',
    fallbackAr: 'الحد الأدنى 8 أحرف',
  );
  String get passwordsNoMatch => userTr(
    'validation.passwordsNoMatch',
    fallbackEn: 'Passwords do not match',
    fallbackAr: 'كلمتا المرور غير متطابقتين',
  );
  String get enterCompanyNumber => userTr(
    'validation.enterCompanyNumber',
    fallbackEn: 'Enter company number',
    fallbackAr: 'أدخل رقم الشركة',
  );
  String get at3Chars => userTr(
    'validation.at3Chars',
    fallbackEn: 'At least 3 characters',
    fallbackAr: 'على الأقل 3 أحرف',
  );
  String get mustBe8Chars => userTr(
    'validation.mustBe8Chars',
    fallbackEn: 'Must be at least 8 characters',
    fallbackAr: 'يجب أن تكون 8 أحرف على الأقل',
  );
  String get mustMatch => userTr(
    'validation.mustMatch',
    fallbackEn: 'Both passwords must match',
    fallbackAr: 'يجب أن تتطابق كلمتا المرور',
  );
  String get acceptTermsMsg => userTr(
    'validation.acceptTermsMsg',
    fallbackEn: 'Please accept terms to continue',
    fallbackAr: 'يرجى قبول الشروط للمتابعة',
  );
  String get enterCode4 => userTr(
    'validation.enterCode4',
    fallbackEn: 'Enter the 4-digit code',
    fallbackAr: 'أدخل الرمز المكون من 4 أرقام',
  );
  String get enterMobileNumber => userTr(
    'validation.enterMobileNumber',
    fallbackEn: 'Enter mobile number',
    fallbackAr: 'أدخل رقم الهاتف',
  );

  // ── Auth ───────────────────────────────────────────────────────────────────
  String get signInToAccount => userTr(
    'auth.signInToAccount',
    fallbackEn: 'Sign in to your\naccount',
    fallbackAr: 'تسجيل الدخول إلى\nحسابك',
  );
  String get createAccount => userTr(
    'auth.createAccount',
    fallbackEn: 'Create your new\naccount',
    fallbackAr: 'إنشاء حسابك\nالجديد',
  );
  String get companyEmailAddress => userTr(
    'auth.companyEmailAddress',
    fallbackEn: 'Company Email Address',
    fallbackAr: 'البريد الإلكتروني للشركة',
  );
  String get emailAddress => userTr(
    'auth.emailAddress',
    fallbackEn: 'Email Address',
    fallbackAr: 'البريد الإلكتروني',
  );
  String get companyEmail => userTr(
    'auth.companyEmail',
    fallbackEn: 'Company Email',
    fallbackAr: 'البريد الإلكتروني',
  );
  String get enterYourEmail => userTr(
    'auth.enterYourEmail',
    fallbackEn: 'Enter your email',
    fallbackAr: 'أدخل بريدك الإلكتروني',
  );
  String get password => userTr(
    'auth.password',
    fallbackEn: 'Password',
    fallbackAr: 'كلمة المرور',
  );
  String get enterYourPassword => userTr(
    'auth.enterYourPassword',
    fallbackEn: 'Enter your password',
    fallbackAr: 'أدخل كلمة المرور',
  );
  String get confirmPassword => userTr(
    'auth.confirmPassword',
    fallbackEn: 'Confirm Password',
    fallbackAr: 'تأكيد كلمة المرور',
  );
  String get confirmYourPassword => userTr(
    'auth.confirmYourPassword',
    fallbackEn: 'Confirm your password',
    fallbackAr: 'تأكيد كلمة المرور',
  );
  String get forgotPassword => userTr(
    'auth.forgotPassword',
    fallbackEn: 'Forgot password?',
    fallbackAr: 'نسيت كلمة المرور؟',
  );
  String get orSignInWith => userTr(
    'auth.orSignInWith',
    fallbackEn: 'Or sign in with',
    fallbackAr: 'أو سجل دخولك بـ',
  );
  String get dontHaveAccount => userTr(
    'auth.dontHaveAccount',
    fallbackEn: "Don't have an account? ",
    fallbackAr: 'ليس لديك حساب؟ ',
  );
  String get signUpBtn =>
      userTr('auth.signUpBtn', fallbackEn: 'Sign up', fallbackAr: 'إنشاء حساب');
  String get alreadyRegistered => userTr(
    'auth.alreadyRegistered',
    fallbackEn: 'Already Registered? ',
    fallbackAr: 'لديك حساب بالفعل؟ ',
  );
  String get signInBtn => userTr(
    'auth.signInBtn',
    fallbackEn: 'Sign In',
    fallbackAr: 'تسجيل الدخول',
  );
  String get companyName => userTr(
    'auth.companyName',
    fallbackEn: 'Company Name',
    fallbackAr: 'اسم الشركة',
  );
  String get enterCompanyName => userTr(
    'auth.enterCompanyName',
    fallbackEn: 'Enter company name',
    fallbackAr: 'أدخل اسم الشركة',
  );
  String get companyNumber => userTr(
    'auth.companyNumber',
    fallbackEn: 'Company Number',
    fallbackAr: 'رقم الشركة',
  );
  String get enterCompanyNumberHint => userTr(
    'auth.enterCompanyNumberHint',
    fallbackEn: 'Enter company number',
    fallbackAr: 'أدخل رقم الشركة',
  );
  String get address =>
      userTr('auth.address', fallbackEn: 'Address', fallbackAr: 'العنوان');
  String get enterAddress => userTr(
    'auth.enterAddress',
    fallbackEn: 'Enter address',
    fallbackAr: 'أدخل العنوان',
  );
  String get taxNumber => userTr(
    'auth.taxNumber',
    fallbackEn: 'Tax number',
    fallbackAr: 'الرقم الضريبي',
  );
  String get enterTaxNumber => userTr(
    'auth.enterTaxNumber',
    fallbackEn: 'Enter tax number',
    fallbackAr: 'أدخل الرقم الضريبي',
  );
  String get agreeTerms => userTr(
    'auth.agreeTerms',
    fallbackEn: 'I Agree with Terms of Service and Privacy Policy',
    fallbackAr: 'أوافق على شروط الخدمة وسياسة الخصوصية',
  );
  String get registration => userTr(
    'auth.registration',
    fallbackEn: 'Registration',
    fallbackAr: 'إنشاء حساب جديد',
  );
  String get personalInfo => userTr(
    'auth.personalInfo',
    fallbackEn: 'Personal Information',
    fallbackAr: 'المعلومات الشخصية',
  );
  String get profilePhoto => userTr(
    'auth.profilePhoto',
    fallbackEn: 'Profile Photo',
    fallbackAr: 'صورة الملف الشخصي',
  );
  String get uploadHint => userTr(
    'auth.uploadHint',
    fallbackEn: 'Click to replace or drag and drop',
    fallbackAr: 'انقر للاستبدال أو اسحب وأفلت',
  );
  String get criminalRecord => userTr(
    'auth.criminalRecord',
    fallbackEn: 'Criminal Record',
    fallbackAr: 'السجل الجنائي',
  );
  String get criminalRecordHint => userTr(
    'auth.criminalRecordHint',
    fallbackEn: "An official document that shows a person's criminal history.",
    fallbackAr: 'وثيقة رسمية توضح التاريخ الجنائي للشخص.',
  );
  String get selectService => userTr(
    'auth.selectService',
    fallbackEn: 'Select Service',
    fallbackAr: 'اختر الخدمة',
  );
  String get aboutMe =>
      userTr('auth.aboutMe', fallbackEn: 'About Me', fallbackAr: 'عني');
  String get yourWork =>
      userTr('auth.yourWork', fallbackEn: 'Your Work', fallbackAr: 'أعمالك');
  String get workImagesHint => userTr(
    'auth.workImagesHint',
    fallbackEn: 'Upload images of your previous work',
    fallbackAr: 'ارفع صوراً لأعمالك السابقة',
  );

  // ── OTP ────────────────────────────────────────────────────────────────────
  String get otpTitle => userTr(
    'otp.otpTitle',
    fallbackEn: 'Email verification',
    fallbackAr: 'التحقق من البريد الإلكتروني',
  );
  String get otpSubtitle => userTr(
    'otp.otpSubtitle',
    fallbackEn: 'Enter the verification code we send you on:',
    fallbackAr: 'أدخل رمز التحقق الذي أرسلناه إليك على:',
  );
  String get didntReceiveCode => userTr(
    'otp.didntReceiveCode',
    fallbackEn: "Didn't receive code? ",
    fallbackAr: 'لم تستقبل الرمز؟ ',
  );
  String get resend =>
      userTr('otp.resend', fallbackEn: 'Resend', fallbackAr: 'إعادة الإرسال');

  // ── Reset / Password Changed ────────────────────────────────────────────────
  String get resetPassword => userTr(
    'reset.resetPassword',
    fallbackEn: 'Reset Password',
    fallbackAr: 'إعادة تعيين كلمة المرور',
  );
  String get resetPasswordSub => userTr(
    'reset.resetPasswordSub',
    fallbackEn:
        'Your new password must be different from the\npreviously used password',
    fallbackAr:
        'يجب أن تكون كلمة المرور الجديدة مختلفة عن\nكلمة المرور المستخدمة سابقًا',
  );
  String get newPassword => userTr(
    'reset.newPassword',
    fallbackEn: 'New Password',
    fallbackAr: 'كلمة المرور الجديدة',
  );
  String get enterNewPassword => userTr(
    'reset.enterNewPassword',
    fallbackEn: 'Enter new password',
    fallbackAr: 'أدخل كلمة المرور الجديدة',
  );
  String get confirmPasswordHint => userTr(
    'reset.confirmPasswordHint',
    fallbackEn: 'Confirm password',
    fallbackAr: 'تأكيد كلمة المرور',
  );
  String get verifyAccount => userTr(
    'reset.verifyAccount',
    fallbackEn: 'Verify Account',
    fallbackAr: 'التحقق من الحساب',
  );
  String get passwordChanged => userTr(
    'reset.passwordChanged',
    fallbackEn: 'Password Changed',
    fallbackAr: 'تم تغيير كلمة المرور',
  );
  String get passwordChangedMsg => userTr(
    'reset.passwordChangedMsg',
    fallbackEn:
        'Password changed successfully, you can login again\nwith a new password',
    fallbackAr:
        'تم تغيير كلمة المرور بنجاح، يمكنك تسجيل الدخول\nمجددًا بكلمة المرور الجديدة',
  );
  String get backToSignIn => userTr(
    'reset.backToSignIn',
    fallbackEn: 'Back to Sign in',
    fallbackAr: 'العودة إلى تسجيل الدخول',
  );

  // ── Onboarding ─────────────────────────────────────────────────────────────
  String get smartSearchTitle => userTr(
    'onboarding.smartSearchTitle',
    fallbackEn: 'Smart Search & Better\nOpportunities',
    fallbackAr: 'بحث ذكي وفرص\nأفضل',
  );
  String get smartSearchSub => userTr(
    'onboarding.smartSearchSub',
    fallbackEn: 'Save time and focus on what \nmatters',
    fallbackAr: 'وفر وقتك وركز على ما يهم',
  );
  String get futureStartsHere => userTr(
    'onboarding.futureStartsHere',
    fallbackEn: 'Your Future Starts Here',
    fallbackAr: 'مستقبلك يبدأ من هنا',
  );
  String get futureStartsSub => userTr(
    'onboarding.futureStartsSub',
    fallbackEn: 'Take the next step toward your\ndream job All in one app',
    fallbackAr: 'اتخذ الخطوة التالية نحو وظيفة أحلامك\nكل شيء في تطبيق واحد',
  );

  // ── Dashboard ──────────────────────────────────────────────────────────────
  String get newCandidates => userTr(
    'dashboard.newCandidates',
    fallbackEn: 'New candidates\nto review',
    fallbackAr: 'مرشحون جدد\nللمراجعة',
  );
  String get scheduleToday => userTr(
    'dashboard.scheduleToday',
    fallbackEn: 'Schedule\nfor today',
    fallbackAr: 'جدول\nاليوم',
  );
  String get messagesReceived => userTr(
    'dashboard.messagesReceived',
    fallbackEn: 'Messages\nreceived',
    fallbackAr: 'الرسائل\nالمستلمة',
  );
  String get jobUpdates => userTr(
    'dashboard.jobUpdates',
    fallbackEn: 'Job Updates',
    fallbackAr: 'تحديثات الوظائف',
  );
  String get deleteJobTitle => userTr(
    'dashboard.deleteJobTitle',
    fallbackEn: 'Delete job post?',
    fallbackAr: 'حذف الإعلان الوظيفي؟',
  );
  String deleteJobContent(String title) => isAr
      ? 'سيتم حذف "$title" نهائيًا.'
      : 'This will permanently delete "$title".';
  String get jobDeleted => userTr(
    'dashboard.jobDeleted',
    fallbackEn: 'Job deleted',
    fallbackAr: 'تم حذف الوظيفة',
  );
  String get appliedOf => userTr(
    'dashboard.appliedOf',
    fallbackEn: 'applied of',
    fallbackAr: 'تقدّم من أصل',
  );
  String get noJobsYet => userTr(
    'dashboard.noJobsYet',
    fallbackEn: 'No jobs yet',
    fallbackAr: 'لا توجد وظائف بعد',
  );

  // ── Jobs ───────────────────────────────────────────────────────────────────
  String get postJob =>
      userTr('jobs.postJob', fallbackEn: 'Post a Job', fallbackAr: 'نشر وظيفة');
  String get editJob => userTr(
    'jobs.editJob',
    fallbackEn: 'Edit Job',
    fallbackAr: 'تعديل الوظيفة',
  );
  String get step1Label => userTr(
    'jobs.step1Label',
    fallbackEn: 'Step 1/3 • Job Information',
    fallbackAr: 'الخطوة 1/3 • معلومات الوظيفة',
  );
  String get step2Label => userTr(
    'jobs.step2Label',
    fallbackEn: 'Step 2/3 • Job Description',
    fallbackAr: 'الخطوة 2/3 • وصف الوظيفة',
  );
  String get step3Label => userTr(
    'jobs.step3Label',
    fallbackEn: 'Step 3/3 • Perks & Benefits',
    fallbackAr: 'الخطوة 3/3 • المزايا والفوائد',
  );
  String get qualifications => userTr(
    'jobs.qualifications',
    fallbackEn: 'Qualifications',
    fallbackAr: 'المؤهلات',
  );
  String get step1Short => userTr(
    'jobs.step1Short',
    fallbackEn: 'Step 1/3',
    fallbackAr: 'الخطوة 1/3',
  );
  String get step2Short => userTr(
    'jobs.step2Short',
    fallbackEn: 'Step 2/3',
    fallbackAr: 'الخطوة 2/3',
  );
  String get step3Short => userTr(
    'jobs.step3Short',
    fallbackEn: 'Step 3/3',
    fallbackAr: 'الخطوة 3/3',
  );
  String get jobTitle => userTr(
    'jobs.jobTitle',
    fallbackEn: 'Job title',
    fallbackAr: 'مسمى الوظيفة',
  );
  String get jobTitleHint => userTr(
    'jobs.jobTitleHint',
    fallbackEn: 'e.g. Software Engineer',
    fallbackAr: 'مثال: مهندس برمجيات',
  );
  String get typeOfEmployment => userTr(
    'jobs.typeOfEmployment',
    fallbackEn: 'Type of Employment',
    fallbackAr: 'نوع التوظيف',
  );
  String get salary =>
      userTr('jobs.salary', fallbackEn: 'Salary', fallbackAr: 'الراتب');
  String get requiredSkills => userTr(
    'jobs.requiredSkills',
    fallbackEn: 'Required skills',
    fallbackAr: 'المهارات المطلوبة',
  );
  String get jobDescriptions => userTr(
    'jobs.jobDescriptions',
    fallbackEn: 'Job Description',
    fallbackAr: 'وصف الوظيفة',
  );
  String get addDescription => userTr(
    'jobs.addDescription',
    fallbackEn: 'Add the description of the job...',
    fallbackAr: 'أضف وصف الوظيفة...',
  );
  String get whatWeProvide => userTr(
    'jobs.whatWeProvide',
    fallbackEn: 'What we provide (optional)',
    fallbackAr: 'ما نقدمه (اختياري)',
  );
  String get addPreferredQual => userTr(
    'jobs.addPreferredQual',
    fallbackEn: 'Add preferred candidate qualifications',
    fallbackAr: 'أضف مؤهلات المرشح المفضلة',
  );
  String get niceToHaves => userTr(
    'jobs.niceToHaves',
    fallbackEn: 'Nice-To-Haves',
    fallbackAr: 'مميزات إضافية',
  );
  String get niceToHavesHint => userTr(
    'jobs.niceToHavesHint',
    fallbackEn: 'Add nice-to-have skills and qualifications',
    fallbackAr: 'أضف مهارات ومؤهلات إضافية',
  );
  String get basicInfo => userTr(
    'jobs.basicInfo',
    fallbackEn: 'Basic Information',
    fallbackAr: 'معلومات أساسية',
  );
  String get basicInfoHint => userTr(
    'jobs.basicInfoHint',
    fallbackEn: 'Basic info about role and company',
    fallbackAr: 'معلومات أساسية عن الدور والشركة',
  );
  String get fullName => userTr(
    'jobs.fullName',
    fallbackEn: 'Full Name',
    fallbackAr: 'الاسم الكامل',
  );
  String get phoneNumber => userTr(
    'jobs.phoneNumber',
    fallbackEn: 'Phone Number',
    fallbackAr: 'رقم الهاتف',
  );
  String get gender =>
      userTr('jobs.gender', fallbackEn: 'Gender', fallbackAr: 'الجنس');
  String get dob => userTr(
    'jobs.dob',
    fallbackEn: 'Date of Birth',
    fallbackAr: 'تاريخ الميلاد',
  );
  String get day => userTr('jobs.day', fallbackEn: 'Day', fallbackAr: 'اليوم');
  String get month =>
      userTr('jobs.month', fallbackEn: 'Month', fallbackAr: 'الشهر');
  String get year =>
      userTr('jobs.year', fallbackEn: 'Year', fallbackAr: 'السنة');
  String get education =>
      userTr('jobs.education', fallbackEn: 'Education', fallbackAr: 'التعليم');
  String get expWork => userTr(
    'jobs.expWork',
    fallbackEn: 'Work Experience',
    fallbackAr: 'خبرات العمل',
  );
  String get portfolioLink => userTr(
    'jobs.portfolioLink',
    fallbackEn: 'Portfolio Link',
    fallbackAr: 'رابط ملف الأعمال',
  );
  String get socialMedia => userTr(
    'jobs.socialMedia',
    fallbackEn: 'Social Media Links',
    fallbackAr: 'روابط التواصل الاجتماعي',
  );
  String get workImages => userTr(
    'jobs.workImages',
    fallbackEn: 'Work Images',
    fallbackAr: 'صور العمل',
  );
  String get saveProfile => userTr(
    'jobs.saveProfile',
    fallbackEn: 'Save Profile',
    fallbackAr: 'حفظ الملف الشخصي',
  );
  String get perksAndBenefits => userTr(
    'jobs.perksAndBenefits',
    fallbackEn: 'Perks and Benefits',
    fallbackAr: 'المزايا والفوائد',
  );
  String get details =>
      userTr('jobs.details', fallbackEn: 'Details', fallbackAr: 'التفاصيل');
  String get listPerks => userTr(
    'jobs.listPerks',
    fallbackEn: 'List perks and benefits (comma separated)',
    fallbackAr: 'اذكر المزايا (مفصولة بفاصلة)',
  );

  // ── Job Details ────────────────────────────────────────────────────────────
  String get descriptionSection => userTr(
    'jobDetails.descriptionSection',
    fallbackEn: 'Description',
    fallbackAr: 'الوصف',
  );
  String get responsibilities => userTr(
    'jobDetails.responsibilities',
    fallbackEn: 'Responsibilities',
    fallbackAr: 'المسؤوليات',
  );
  String get niceToHavesSection => userTr(
    'jobDetails.niceToHavesSection',
    fallbackEn: 'Nice-To-Haves',
    fallbackAr: 'مميزات إضافية',
  );
  String get aboutThisRole => userTr(
    'jobDetails.aboutThisRole',
    fallbackEn: 'About this role',
    fallbackAr: 'عن هذه الوظيفة',
  );
  String get salaryLabel => userTr(
    'jobDetails.salaryLabel',
    fallbackEn: 'Salary',
    fallbackAr: 'الراتب',
  );
  String get jobTypeLabel => userTr(
    'jobDetails.jobTypeLabel',
    fallbackEn: 'Job Type',
    fallbackAr: 'نوع الوظيفة',
  );
  String get categoryLabel => userTr(
    'jobDetails.categoryLabel',
    fallbackEn: 'Classification',
    fallbackAr: 'التصنيف',
  );
  String get noDescriptionYet => userTr(
    'jobDetails.noDescriptionYet',
    fallbackEn: 'No description yet.',
    fallbackAr: 'لا يوجد وصف بعد.',
  );
  String get noItemsYet => userTr(
    'jobDetails.noItemsYet',
    fallbackEn: 'No items yet',
    fallbackAr: 'لا توجد عناصر بعد',
  );
  String get tableView =>
      userTr('jobDetails.tableView', fallbackEn: 'Table', fallbackAr: 'جدول');
  String get pipelineView => userTr(
    'jobDetails.pipelineView',
    fallbackEn: 'Pipeline',
    fallbackAr: 'خط سير',
  );
  String get locationLabel => userTr(
    'jobDetails.locationLabel',
    fallbackEn: 'Location',
    fallbackAr: 'الموقع',
  );
  String get employmentTypeLabel => userTr(
    'jobDetails.employmentTypeLabel',
    fallbackEn: 'Employment type',
    fallbackAr: 'نوع التوظيف',
  );
  String get salaryRangeLabel => userTr(
    'jobDetails.salaryRangeLabel',
    fallbackEn: 'Salary range',
    fallbackAr: 'نطاق الراتب',
  );
  String get titleLabel => userTr(
    'jobDetails.titleLabel',
    fallbackEn: 'Title',
    fallbackAr: 'العنوان',
  );
  String get inReview => userTr(
    'jobDetails.inReview',
    fallbackEn: 'In Review',
    fallbackAr: 'قيد المراجعة',
  );
  String get shortlisted => userTr(
    'jobDetails.shortlisted',
    fallbackEn: 'Shortlisted',
    fallbackAr: 'في القائمة المختصرة',
  );

  // ── Profile / Overview ─────────────────────────────────────────────────────
  String get profileSettings => userTr(
    'profile.profileSettings',
    fallbackEn: 'Profile Settings',
    fallbackAr: 'إعدادات الملف الشخصي',
  );
  String get overviewSection => userTr(
    'profile.overviewSection',
    fallbackEn: 'Overview',
    fallbackAr: 'نظرة عامة',
  );
  String get socialLinks => userTr(
    'profile.socialLinks',
    fallbackEn: 'Social Links',
    fallbackAr: 'روابط التواصل',
  );
  String get companyLogo => userTr(
    'profile.companyLogo',
    fallbackEn: 'Company Logo',
    fallbackAr: 'شعار الشركة',
  );
  String get logoHint => userTr(
    'profile.logoHint',
    fallbackEn: 'Click to replace or drag and drop',
    fallbackAr: 'انقر للاستبدال أو اسحب وأفلت',
  );
  String get website => userTr(
    'profile.website',
    fallbackEn: 'Website',
    fallbackAr: 'الموقع الإلكتروني',
  );
  String get classification => userTr(
    'profile.classification',
    fallbackEn: 'Staff',
    fallbackAr: 'طاقم العمل',
  );
  String get industry => userTr(
    'profile.industry',
    fallbackEn: 'Field of work',
    fallbackAr: 'مجال العمل',
  );
  String get dateFounded => userTr(
    'profile.dateFounded',
    fallbackEn: 'Date Founded',
    fallbackAr: 'تاريخ التأسيس',
  );
  String get aboutCompany => userTr(
    'profile.aboutCompany',
    fallbackEn: 'About Company',
    fallbackAr: 'عن الشركة',
  );
  String get previewProfile => userTr(
    'profile.previewProfile',
    fallbackEn: 'Preview Company Profile',
    fallbackAr: 'معاينة ملف الشركة',
  );

  // ── Help Center ────────────────────────────────────────────────────────────
  String get helpCenter => userTr(
    'help.helpCenter',
    fallbackEn: 'Help Center',
    fallbackAr: 'مركز المساعدة',
  );
  String get searchHelp => userTr(
    'help.searchHelp',
    fallbackEn: 'Search help',
    fallbackAr: 'البحث في المساعدة',
  );
  String get popularArticles => userTr(
    'help.popularArticles',
    fallbackEn: 'Popular articles',
    fallbackAr: 'المقالات الشائعة',
  );

  // ── Messages / Chat ────────────────────────────────────────────────────────
  String get messages =>
      userTr('chat.messages', fallbackEn: 'Messages', fallbackAr: 'الرسائل');
  String get replyMessage => userTr(
    'chat.replyMessage',
    fallbackEn: 'Reply message',
    fallbackAr: 'اكتب ردك',
  );

  String get editProfile => userTr(
    'profile.editProfile',
    fallbackEn: 'Edit Profile',
    fallbackAr: 'تعديل الملف الشخصي',
  );
  String get aboutMeSection =>
      userTr('profile.aboutMe', fallbackEn: 'About Me', fallbackAr: 'عني');
  String get workExperience => userTr(
    'profile.workExperience',
    fallbackEn: 'Work Experience',
    fallbackAr: 'خبرة العمل',
  );
  String get skills =>
      userTr('profile.skills', fallbackEn: 'Skills', fallbackAr: 'المهارات');
  String get portfolioUrl => userTr(
    'profile.portfolioUrl',
    fallbackEn: 'Portfolio URL',
    fallbackAr: 'رابط الأعمال',
  );
  String get additionalDetails => userTr(
    'profile.additionalDetails',
    fallbackEn: 'Additional Details',
    fallbackAr: 'تفاصيل إضافية',
  );
  String get email => userTr(
    'common.email',
    fallbackEn: 'Email',
    fallbackAr: 'البريد الإلكتروني',
  );
  String get phone =>
      userTr('common.phone', fallbackEn: 'Phone', fallbackAr: 'الهاتف');

  // ── Company Candidates ─────────────────────────────────────────────────────
  String get hired =>
      userTr('candidates.hired', fallbackEn: 'Hired', fallbackAr: 'تم التوظيف');
  String get declined => userTr(
    'candidates.declined',
    fallbackEn: 'Declined',
    fallbackAr: 'مرفوض',
  );
  String get candidateHiredMsg => userTr(
    'candidates.candidateHiredMsg',
    fallbackEn: 'Candidate has been hired',
    fallbackAr: 'تم توظيف المرشح',
  );
  String get candidateDeclinedMsg => userTr(
    'candidates.candidateDeclinedMsg',
    fallbackEn: 'Candidate has been declined',
    fallbackAr: 'تم رفض المرشح',
  );
  String get hiringProgress => userTr(
    'candidates.hiringProgress',
    fallbackEn: 'Hiring Pipeline',
    fallbackAr: 'مسار التوظيف',
  );
  String get currentStage => userTr(
    'candidates.currentStage',
    fallbackEn: 'Current Stage',
    fallbackAr: 'المرحلة الحالية',
  );
  String get moveToNextStep => userTr(
    'candidates.moveToNextStep',
    fallbackEn: 'Move to Next Step',
    fallbackAr: 'الانتقال للخطوة التالية',
  );
  String get notes =>
      userTr('candidates.notes', fallbackEn: 'Notes', fallbackAr: 'الملاحظات');
  String get addFeedback => userTr(
    'candidates.addFeedback',
    fallbackEn: 'Add Feedback',
    fallbackAr: 'إضافة ملاحظات',
  );
  String get mostRelevant => userTr(
    'candidates.mostRelevant',
    fallbackEn: 'Most Relevant',
    fallbackAr: 'الأكثر صلة',
  );

  // ── Company Help ───────────────────────────────────────────────────────────
  String get didntFindWhat => userTr(
    'help.didntFindWhat',
    fallbackEn: "Didn't find what you were looking for?",
    fallbackAr: 'لم تجد ما كنت تبحث عنه؟',
  );
  String get contactCustomerService => userTr(
    'help.contactCustomerService',
    fallbackEn: 'Contact our customer service',
    fallbackAr: 'اتصل بخدمة العملاء',
  );
  String get contactUs => userTr(
    'help.contactUs',
    fallbackEn: 'Contact Us',
    fallbackAr: 'اتصل بنا',
  );
  String get wasArticleHelpful => userTr(
    'help.wasArticleHelpful',
    fallbackEn: 'Was this article helpful?',
    fallbackAr: 'هل كان هذا المقال مفيدًا؟',
  );

  // ── Company Jobs ───────────────────────────────────────────────────────────
  String get deleteJobTooltip => userTr(
    'jobs.deleteJobTooltip',
    fallbackEn: 'Delete Job',
    fallbackAr: 'حذف الوظيفة',
  );
  String get openFullTable => userTr(
    'jobs.openFullTable',
    fallbackEn: 'Open Full Table',
    fallbackAr: 'فتح الجدول الكامل',
  );
  String get openFullPipeline => userTr(
    'jobs.openFullPipeline',
    fallbackEn: 'Open Full Pipeline',
    fallbackAr: 'فتح المسار الكامل',
  );
  String get editJobTitle => userTr(
    'jobs.editJobTitle',
    fallbackEn: 'Edit Job Title',
    fallbackAr: 'تعديل مسمى الوظيفة',
  );

  // ── Company Profile ────────────────────────────────────────────────────────
  String get about =>
      userTr('profile.about', fallbackEn: 'About', fallbackAr: 'عن الشركة');
  String get locationInfo => userTr(
    'profile.locationInfo',
    fallbackEn: 'Location',
    fallbackAr: 'الموقع',
  );
  String get contactSectionLabel => userTr(
    'profile.contactSection',
    fallbackEn: 'Contact',
    fallbackAr: 'التواصل',
  );
  String get addSocialLink => userTr(
    'profile.addSocialLink',
    fallbackEn: 'Add Social Link',
    fallbackAr: 'إضافة رابط تواصل',
  );
  String get editSocialLink => userTr(
    'profile.editSocialLink',
    fallbackEn: 'Edit Social Link',
    fallbackAr: 'تعديل رابط التواصل',
  );
  String get nameLabel =>
      userTr('profile.nameLabel', fallbackEn: 'Name', fallbackAr: 'الاسم');
  String get urlHandle => userTr(
    'profile.urlHandle',
    fallbackEn: 'URL / Handle',
    fallbackAr: 'الرابط / المعرّف',
  );
  String get socialLinksHint => userTr(
    'profile.socialLinksHint',
    fallbackEn: 'Add your social media links',
    fallbackAr: 'أضف روابط التواصل الاجتماعي',
  );

  // ── Gender ─────────────────────────────────────────────────────────────────
  String get male =>
      userTr('common.male', fallbackEn: 'Male', fallbackAr: 'ذكر');
  String get female =>
      userTr('common.female', fallbackEn: 'Female', fallbackAr: 'أنثى');

  // ── Applicant Details ──────────────────────────────────────────────────────
  String get applicantDetails => userTr(
    'candidates.applicantDetails',
    fallbackEn: 'Applicant Details',
    fallbackAr: 'تفاصيل المتقدم',
  );
  String get contactSection => userTr(
    'candidates.contactSection',
    fallbackEn: 'Contact',
    fallbackAr: 'التواصل',
  );
  String get quickActions => userTr(
    'candidates.quickActions',
    fallbackEn: 'Quick Actions',
    fallbackAr: 'الإجراءات السريعة',
  );
  String get resumeLabel => userTr(
    'candidates.resumeLabel',
    fallbackEn: 'Resume',
    fallbackAr: 'السيرة الذاتية',
  );
  String get lastUsed => userTr(
    'candidates.lastUsed',
    fallbackEn: 'Last Used',
    fallbackAr: 'آخر استخدام',
  );

  String get technical => tr(en: 'Technical', ar: 'تقني');
  String get nonTechnical => tr(en: 'Non-Technical', ar: 'غير تقني');
  String get benefits => tr(en: 'Benefits', ar: 'المزايا');
  String get addBenefit => tr(en: 'Add Benefit', ar: 'إضافة ميزة');

  String get accountSecurity => tr(en: 'Account Security', ar: 'أمان الحساب');
  String get linkGoogleAccount =>
      tr(en: 'Link Google Account', ar: 'ربط حساب جوجل');
  String get linkGoogleDesc => tr(
    en: 'Link your account to enable one-tap login.',
    ar: 'اربط حسابك لتفعيل تسجيل الدخول بضغطة واحدة.',
  );
  String get accountNotLinked =>
      tr(en: 'Account not linked yet', ar: 'الحساب غير مرتبط بعد');
  String get continueWithGoogle =>
      tr(en: 'Continue with Google', ar: 'المتابعة باستخدام جوجل');
  String get currentPassword =>
      tr(en: 'Current Password', ar: 'كلمة المرور الحالية');
  String get newPasswordLabel =>
      tr(en: 'New Password', ar: 'كلمة المرور الجديدة');
  String get confirmNewPassword =>
      tr(en: 'Confirm New Password', ar: 'تأكيد كلمة المرور الجديدة');
  String get hiredStatusUpdate =>
      tr(en: 'Applicant status updated to:', ar: 'تم تحديث حالة المتقدم إلى:');
  String get newChat => tr(en: 'New Chat', ar: 'محادثة جديدة');
  String get searchUsersHint => tr(
    en: 'Search users by name or email...',
    ar: 'ابحث عن مستخدمين بالاسم أو الإيميل...',
  );
  String get startNewConversation =>
      tr(en: 'Starting a new conversation...', ar: 'بدء محادثة جديدة...');
  String get applicantAcceptedTitle =>
      tr(en: 'Applicant Accepted!', ar: 'تم قبول المتقدم بنجاح!');
  String hiredCongratulation(String name) => isAr
      ? 'تهانينا! لقد قمت بتوظيف $name.'
      : 'Congratulations! You have hired $name.';
  String get evaluationReminder => tr(
    en: 'Reminder: We will notify you to evaluate the employee and write feedback about their performance in 2 months.',
    ar: 'تنبيه: سنقوم بتذكيرك لتقييم الموظف وكتابة تعليق عن أدائه بعد شهرين من الآن.',
  );
  String hiredProgressMsg(int count, int total) => isAr
      ? '$count تم قبولهم من أصل $total'
      : '$count hired of $total capacity';

  // ── Unknown route ──────────────────────────────────────────────────────────
  String get unknownRoute => userTr(
    'common.unknownRoute',
    fallbackEn: 'Unknown route',
    fallbackAr: 'مسار غير معروف',
  );
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      const ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final lang = locale.languageCode.toLowerCase().startsWith('ar')
        ? 'ar'
        : 'en';
    final userStrings = await _loadMap('assets/l10n/user_$lang.json');
    final companyStrings = await _loadMap('assets/l10n/company_$lang.json');
    return AppLocalizations(
      locale,
      userStrings: userStrings,
      companyStrings: companyStrings,
    );
  }

  Future<Map<String, dynamic>> _loadMap(String path) async {
    try {
      final raw = await rootBundle.loadString(path);
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      return const <String, dynamic>{};
    } catch (_) {
      return const <String, dynamic>{};
    }
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
