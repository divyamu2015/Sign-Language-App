class AppConfig {
  // ─── Backend Configuration ───────────────────────────────────────────────
  static const String baseUri = 'https://5h44kl7q-8001.inc1.devtunnels.ms';

  // ─── Authentication Endpoints ─────────────────────────────────────────────
  static const String userRegistration = '$baseUri/api/auth/register';
  static const String userLoginuri = '$baseUri/api/auth/login';
  static const String validateToken = '$baseUri/api/auth/validate-token';

  // ─── Learning & Categories ────────────────────────────────────────────────
  static const String categoriesUri = '$baseUri/api/categories';
  static String getLessonsUri(int categoryId) => '$baseUri/api/categories/$categoryId/lessons';
  static String getLessonDetailUri(int lessonId) => '$baseUri/api/lessons/$lessonId';

  // ─── Quizzes & Modules ────────────────────────────────────────────────────
  static String getLevelQuestionsUri(int levelId) => '$baseUri/api/levels/$levelId/questions';
  static String submitLevelAnswersUri(int levelId) => '$baseUri/api/levels/$levelId/submit';
  static String completeModuleUri(int moduleId) => '$baseUri/api/modules/$moduleId/complete';

  // ─── User Profile & Vitals ────────────────────────────────────────────────
  static const String userVitalsUri = '$baseUri/api/user/vitals';
  static const String dailyCheckinUri = '$baseUri/api/user/daily-checkin';
  static const String userMilestonesUri = '$baseUri/api/user/milestones';
  static const String userAchievementsUri = '$baseUri/api/user/achievements';
  static String viewProfileUri(int userId) => '$baseUri/userapp/view_profile/$userId/';
  static String updateProfileUri(int userId) => '$baseUri/userapp/profile/update/$userId/';

  // ─── Social & AI ──────────────────────────────────────────────────────────
  static const String leaderboardUri = '$baseUri/api/leaderboard';
  static const String verifyGestureUri = '$baseUri/api/ai/verify-gesture';

  // ─── App Settings & Feedback ──────────────────────────────────────────────
  static const String appConfigUri = '$baseUri/api/app/config';
  static const String userFeedbackUri = '$baseUri/api/user/feedback';

  // ─── Legacy / Compatibility ───────────────────────────────────────────────
  static const String categoryView = categoriesUri;
  static const String getLevels = '$baseUri/api/levels';

  // ─── Developer / Demo Settings ────────────────────────────────────────────
  static const bool useDemoMode = false;
  static const int demoUserId = 1;
  static const String demoUserName = "Alex";
}
