# Staff-Principal Appointment Management System

A comprehensive, secure, real-time appointment scheduling system built with Flutter and Firebase, designed to streamline communication between staff members and principals.

## 🚀 Features

### Core Functionality
- **Real-time Appointment Scheduling**: Create, manage, and track appointments with live updates
- **Role-based Access Control**: Separate interfaces for staff and principals
- **Audio Message Support**: Record and attach voice messages to appointments
- **Push Notifications**: Real-time alerts for appointment updates
- **Calendar Integration**: Visual calendar view with appointment management
- **Conflict Detection**: Automatic scheduling conflict prevention
- **Offline Support**: Local caching for offline functionality

### Security Features
- **Firebase Authentication**: Secure email/password authentication
- **Data Encryption**: End-to-end encryption for sensitive data
- **Rate Limiting**: Protection against abuse and spam
- **Session Management**: Secure session handling with timeout
- **Role-based Permissions**: Granular access control

### Technical Features
- **Cross-platform**: iOS and Android support
- **Material Design 3**: Modern, accessible UI design
- **Performance Monitoring**: Built-in performance tracking
- **Analytics**: User behavior and app usage analytics
- **Error Handling**: Comprehensive error management
- **Testing**: Unit, integration, and widget tests

## 📱 Screenshots

[Add screenshots of your app here]

## 🏗️ Architecture

### Project Structure
```
lib/
├── core/
│   ├── config/          # App configuration
│   ├── models/          # Data models
│   ├── providers/       # State management
│   ├── services/        # Business logic services
│   └── utils/           # Utilities and helpers
├── presentation/
│   ├── screens/         # UI screens
│   ├── widgets/         # Reusable widgets
│   └── theme/           # App theming
└── main.dart           # App entry point
```

### Key Components

#### Services
- **AuthService**: User authentication and management
- **AppointmentService**: Appointment CRUD operations
- **AudioService**: Audio recording and TTS functionality
- **NotificationService**: Push notifications and local alerts
- **CacheService**: Offline data caching
- **PerformanceService**: Performance monitoring
- **AnalyticsService**: Usage analytics

#### Providers (State Management)
- **AuthProvider**: Authentication state
- **AppointmentProvider**: Appointment data management
- **AudioProvider**: Audio playback and recording state

## 🛠️ Installation

### Prerequisites
- Flutter SDK (>=3.10.0)
- Dart SDK (>=3.0.0)
- Firebase project setup
- Android Studio / Xcode for mobile development

### Setup Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/staff-principal-appointments.git
   cd staff-principal-appointments
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project
   - Enable Authentication, Firestore, Storage, and Messaging
   - Download configuration files:
     - `google-services.json` for Android (place in `android/app/`)
     - `GoogleService-Info.plist` for iOS (place in `ios/Runner/`)

4. **Configure Firebase Security Rules**
   ```bash
   # Deploy Firestore rules
   firebase deploy --only firestore:rules
   
   # Deploy Storage rules
   firebase deploy --only storage
   ```

5. **Environment Configuration**
   - Update `lib/core/config/app_config.dart` with your configuration
   - Set up Google Cloud TTS API key (optional)

6. **Run the app**
   ```bash
   flutter run
   ```

## 🔧 Configuration

### Firebase Configuration
Update the Firebase configuration in `lib/core/config/app_config.dart`:

```dart
class AppConfig {
  static const String firebaseProjectId = 'your-project-id';
  static const String gcloudApiKey = 'your-google-cloud-api-key';
  // ... other configurations
}
```

### Security Rules
The app includes comprehensive Firebase security rules:

- **Firestore Rules**: Located in `firebase_rules/firestore.rules`
- **Storage Rules**: Located in `firebase_rules/storage.rules`

### Permissions
Required permissions are automatically handled, but ensure these are configured:

#### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

#### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access to record audio messages</string>
```

## 🧪 Testing

### Running Tests

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Test coverage
flutter test --coverage
```

### Test Structure
- **Unit Tests**: `test/unit/` - Service and utility testing
- **Integration Tests**: `test/integration/` - End-to-end flow testing
- **Widget Tests**: `test/widget/` - UI component testing

## 📊 Performance

### Monitoring
The app includes built-in performance monitoring:

```dart
// Track operation performance
PerformanceService.startOperation('appointment_creation');
// ... perform operation
PerformanceService.endOperation('appointment_creation');
```

### Optimization Features
- **Lazy Loading**: Efficient data loading
- **Image Caching**: Optimized image handling
- **Memory Management**: Proper resource disposal
- **Network Optimization**: Request batching and caching

## 📈 Analytics

Track user behavior and app usage:

```dart
// Track events
AnalyticsService.trackEvent('appointment_created');
AnalyticsService.trackScreenView('dashboard');

// Generate reports
final report = AnalyticsService.generateReport();
```

## 🔒 Security

### Data Protection
- **Encryption**: All sensitive data is encrypted
- **Authentication**: Secure Firebase Authentication
- **Authorization**: Role-based access control
- **Validation**: Input validation and sanitization

### Best Practices
- Regular security audits
- Dependency updates
- Secure coding practices
- Privacy compliance

## 🚀 Deployment

### Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

### iOS
```bash
# Build iOS
flutter build ios --release
```

### CI/CD
The project includes GitHub Actions workflows for:
- Automated testing
- Code quality checks
- Build verification
- Deployment automation

## 📚 API Documentation

### Core Services

#### AppointmentService
```dart
// Create appointment
final appointment = await AppointmentService.createAppointment(appointmentModel);

// Update status
await AppointmentService.updateAppointmentStatus(id, AppointmentStatus.accepted);

// Get user appointments
final appointments = await AppointmentService.getUserAppointments(userId, userRole);
```

#### AudioService
```dart
// Start recording
await AudioService.startRecording();

// Stop recording
final audioPath = await AudioService.stopRecording();

// Generate TTS
final audioUrl = await AudioService.generateTextToSpeech(text);
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow Flutter/Dart style guidelines
- Write comprehensive tests
- Update documentation
- Ensure security best practices

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

### Documentation
- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)

### Issues
If you encounter any issues, please file a bug report on the [Issues](https://github.com/yourusername/staff-principal-appointments/issues) page.

### Contact
- Email: support@yourcompany.com
- Documentation: [Project Wiki](https://github.com/yourusername/staff-principal-appointments/wiki)

## 🎯 Roadmap

### Upcoming Features
- [ ] Video call integration
- [ ] Advanced calendar features
- [ ] Multi-language support
- [ ] Dark mode enhancements
- [ ] Advanced analytics dashboard
- [ ] Integration with external calendar systems

### Version History
- **v1.0.0** - Initial release with core functionality
- **v1.1.0** - Audio message improvements and performance optimization
- **v1.2.0** - Enhanced security and offline support

---

**Built with ❤️ using Flutter and Firebase**