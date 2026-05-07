class UserProfileData {
  static String fullName = "";
  static String aboutMe = "";
  static String phone = "";
  static String email = "";
  static String dob = "";
  static String gender = "";
  static String portfolioUrl = "";
  static String location = "";
  static String jobTitle = "";
  static String? cvName;
  /// Kept in sync with [RecruitmentSyncStore.profileImage] when the user sets a photo.
  static String? profileImage;
  static String? coverImage;
  
  static List<String> skills = [];
  static List<Map<String, String>> socialLinks = [];
  static List<Map<String, String>> experiences = [];
  static List<Map<String, String>> education = [];
  static List<String> portfolioImages = [];
  
  static double minSalary = 0;
  static double maxSalary = 0;
  static String salaryFrequency = "Monthly";
}
