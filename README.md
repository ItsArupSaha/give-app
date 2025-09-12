# Gaura-vāṇī Institute for Vaiṣṇava Education (GIVE)

## Features

### 🏫 Course Management
- **Course Groups**: Organize courses into groups (e.g., "IDC", "Bhakti Sastri", "Sanskrit")
- **Batches**: Create multiple batches under each course group
- **Class Codes**: Generate unique codes for students to join batches

### 👨‍🏫 Teacher Features
- Create and manage course groups
- Create and manage batches
- Generate class codes for student enrollment
- Create and assign tasks with deadlines
- Grade student submissions
- Monitor student progress
- Manage course materials

### 👨‍🎓 Student Features
- Join batches using class codes
- View assigned tasks and deadlines
- Submit assignments in various formats
- Track progress and grades
- Participate in class discussions
- Access course materials

### 💬 Communication
- Public comments in batch streams
- Private comments on specific tasks
- Real-time notifications
- File sharing and attachments

## Tech Stack

- **Frontend**: Flutter with Material Design 3
- **Backend**: Firebase (Firestore, Authentication, Storage)
- **State Management**: Provider
- **UI**: Google Fonts, Custom Theming
- **File Handling**: File Picker, Firebase Storage

## Project Structure

```
lib/
├── constants/          # App constants and configuration
├── models/            # Data models (User, CourseGroup, Batch, etc.)
├── screens/           # UI screens
│   ├── auth/         # Authentication screens
│   ├── teacher/      # Teacher-specific screens
│   └── student/      # Student-specific screens
├── services/          # Firebase services
├── providers/         # State management
├── utils/            # Helper functions
└── widgets/          # Reusable UI components
```

## Setup Instructions

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code
- Firebase account

### 1. Clone the Repository
```bash
git clone <repository-url>
cd give_app
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Setup

#### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project named "Gauravani-institute"
3. Enable Authentication, Firestore Database, and Storage

#### Configure Authentication
1. Go to Authentication > Sign-in method
2. Enable Email/Password authentication
3. Optionally enable Google Sign-in

#### Configure Firestore Database
1. Go to Firestore Database
2. Create database in production mode
3. Set up security rules (see below)

#### Configure Storage
1. Go to Storage
2. Create storage bucket
3. Set up security rules

#### Update Firebase Configuration
1. Go to Project Settings > General
2. Add your app (Android/iOS/Web)
3. Download the configuration files
4. Update `lib/firebase_options.dart` with your actual Firebase configuration

### 4. Security Rules

#### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Course groups - only teachers can create, everyone can read
    match /courseGroups/{groupId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        resource.data.teacherId == request.auth.uid;
    }
    
    // Batches - only teachers can create, enrolled students can read
    match /batches/{batchId} {
      allow read: if request.auth != null && 
        (resource.data.teacherId == request.auth.uid ||
         exists(/databases/$(database)/documents/enrollments/$(request.auth.uid + '_' + batchId)));
      allow write: if request.auth != null && 
        resource.data.teacherId == request.auth.uid;
    }
    
    // Tasks - only teachers can create, enrolled students can read
    match /tasks/{taskId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Submissions - students can create/update their own, teachers can read all
    match /submissions/{submissionId} {
      allow read, write: if request.auth != null;
    }
    
    // Comments - authenticated users can read/write
    match /comments/{commentId} {
      allow read, write: if request.auth != null;
    }
    
    // Enrollments - students can create, teachers can read
    match /enrollments/{enrollmentId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

#### Storage Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 5. Run the Application
```bash
flutter run
```

## Development

### Adding New Features
1. Create models in `lib/models/`
2. Add services in `lib/services/`
3. Create providers in `lib/providers/`
4. Build UI screens in `lib/screens/`
5. Add reusable widgets in `lib/widgets/`

### Code Style
- Follow Flutter/Dart conventions
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused
- Use const constructors where possible

### Testing
```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/
```

## Deployment

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please contact the development team or create an issue in the repository.

## Roadmap

- [ ] Real-time notifications
- [ ] Offline support
- [ ] Advanced analytics
- [ ] Mobile app deployment
- [ ] Web version
- [ ] Multi-language support
- [ ] Video conferencing integration
- [ ] Advanced file management
- [ ] Grade book
- [ ] Attendance tracking