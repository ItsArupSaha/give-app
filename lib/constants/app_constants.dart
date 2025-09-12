class AppConstants {
  // App Information
  static const String appName = 'Gauravanai Institute';
  static const String appVersion = '1.0.0';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String courseGroupsCollection = 'courseGroups';
  static const String batchesCollection = 'batches';
  static const String tasksCollection = 'tasks';
  static const String submissionsCollection = 'submissions';
  static const String commentsCollection = 'comments';
  static const String enrollmentsCollection = 'enrollments';
  
  // Storage Paths
  static const String profileImagesPath = 'profile_images';
  static const String taskAttachmentsPath = 'task_attachments';
  static const String submissionFilesPath = 'submission_files';
  static const String courseGroupImagesPath = 'course_group_images';
  
  // File Upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx', 'txt'];
  static const List<String> allowedVideoTypes = ['mp4', 'avi', 'mov'];
  static const List<String> allowedAudioTypes = ['mp3', 'wav', 'm4a'];
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Class Code
  static const int classCodeLength = 8;
  static const String classCodeChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  
  // Task Points
  static const int defaultMaxPoints = 100;
  static const int minPoints = 0;
  static const int maxPoints = 1000;
  
  // Notification
  static const String notificationChannelId = 'gauravanai_notifications';
  static const String notificationChannelName = 'Gauravanai Notifications';
  static const String notificationChannelDescription = 'Notifications for tasks, comments, and updates';
}

class AppColors {
  // Primary Colors (Spiritual/Educational Theme)
  static const int primaryColorValue = 0xFF2E7D32; // Deep Green
  static const int secondaryColorValue = 0xFF4CAF50; // Light Green
  static const int accentColorValue = 0xFFFFC107; // Golden Yellow
  
  // Background Colors
  static const int backgroundColorValue = 0xFFF5F5F5; // Light Gray
  static const int surfaceColorValue = 0xFFFFFFFF; // White
  static const int cardColorValue = 0xFFFFFFFF; // White
  
  // Text Colors
  static const int primaryTextColorValue = 0xFF212121; // Dark Gray
  static const int secondaryTextColorValue = 0xFF757575; // Medium Gray
  static const int hintTextColorValue = 0xFFBDBDBD; // Light Gray
  
  // Status Colors
  static const int successColorValue = 0xFF4CAF50; // Green
  static const int warningColorValue = 0xFFFF9800; // Orange
  static const int errorColorValue = 0xFFF44336; // Red
  static const int infoColorValue = 0xFF2196F3; // Blue
  
  // Task Status Colors
  static const int draftColorValue = 0xFF9E9E9E; // Gray
  static const int publishedColorValue = 0xFF4CAF50; // Green
  static const int closedColorValue = 0xFFF44336; // Red
  static const int overdueColorValue = 0xFFFF5722; // Deep Orange
}

class AppStrings {
  // Common
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String create = 'Create';
  static const String update = 'Update';
  static const String submit = 'Submit';
  static const String back = 'Back';
  static const String next = 'Next';
  static const String done = 'Done';
  static const String close = 'Close';
  
  // Authentication
  static const String login = 'Login';
  static const String register = 'Register';
  static const String logout = 'Logout';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String resetPassword = 'Reset Password';
  static const String name = 'Name';
  static const String role = 'Role';
  
  // Course Groups
  static const String courseGroups = 'Course Groups';
  static const String createCourseGroup = 'Create Course Group';
  static const String editCourseGroup = 'Edit Course Group';
  static const String courseGroupName = 'Course Group Name';
  static const String courseGroupDescription = 'Description';
  
  // Batches
  static const String batches = 'Batches';
  static const String createBatch = 'Create Batch';
  static const String editBatch = 'Edit Batch';
  static const String batchName = 'Batch Name';
  static const String batchDescription = 'Description';
  static const String classCode = 'Class Code';
  static const String joinBatch = 'Join Batch';
  static const String leaveBatch = 'Leave Batch';
  
  // Tasks
  static const String tasks = 'Tasks';
  static const String createTask = 'Create Task';
  static const String editTask = 'Edit Task';
  static const String taskTitle = 'Task Title';
  static const String taskDescription = 'Description';
  static const String dueDate = 'Due Date';
  static const String maxPoints = 'Max Points';
  static const String attachments = 'Attachments';
  static const String instructions = 'Instructions';
  
  // Submissions
  static const String submissions = 'Submissions';
  static const String submitTask = 'Submit Task';
  static const String resubmit = 'Resubmit';
  static const String grade = 'Grade';
  static const String feedback = 'Feedback';
  static const String points = 'Points';
  
  // Comments
  static const String comments = 'Comments';
  static const String addComment = 'Add Comment';
  static const String reply = 'Reply';
  static const String publicComment = 'Public Comment';
  static const String privateComment = 'Private Comment';
  
  // Dashboard
  static const String dashboard = 'Dashboard';
  static const String teacherDashboard = 'Teacher Dashboard';
  static const String studentDashboard = 'Student Dashboard';
  static const String recentActivity = 'Recent Activity';
  static const String statistics = 'Statistics';
  
  // Navigation
  static const String home = 'Home';
  static const String profile = 'Profile';
  static const String settings = 'Settings';
  static const String notifications = 'Notifications';
  
  // Messages
  static const String noDataFound = 'No data found';
  static const String somethingWentWrong = 'Something went wrong';
  static const String tryAgain = 'Try Again';
  static const String networkError = 'Network Error';
  static const String permissionDenied = 'Permission Denied';
}
