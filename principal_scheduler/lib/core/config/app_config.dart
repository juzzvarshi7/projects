class AppConfig {
  static const String appName = 'Staff-Principal Appointments';
  static const String version = '1.0.0';
  
  // Firebase Configuration
  static const String firebaseProjectId = 'staff-principal-appointments';
  
  // Google Cloud TTS Configuration
  static const String gcloudApiKey = 'YOUR_GOOGLE_CLOUD_API_KEY';
  
  // Audio Configuration
  static const int maxAudioDurationMinutes = 5;
  static const String audioFormat = 'mp3';
  
  // Notification Configuration
  static const String notificationChannelId = 'appointment_notifications';
  static const String notificationChannelName = 'Appointment Notifications';
  
  // Security Configuration
  static const int sessionTimeoutMinutes = 30;
  static const int maxLoginAttempts = 5;
  
  // Rate Limiting
  static const int maxAppointmentsPerDay = 10;
  static const int maxAudioMessagesPerHour = 20;
}