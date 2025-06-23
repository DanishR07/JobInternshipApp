
# Internships & Job Portal App

A mobile application developed using **Flutter** and **Firebase** that helps users explore internships, apply for jobs, manage their profile, receive notifications, and more — all in a seamless and intuitive interface.

---

## ✨ Features

- 🔐 **User Authentication** via Firebase Authentication
- 👤 **User Profile Management**: View and update user profiles with real-time data
- 💼 **Job & Internship Listings**: View a variety of job and internship opportunities
- 📝 **Apply for Jobs/Internships**: Track and manage applied positions
- 🔔 **Push Notifications** using Firebase Cloud Messaging (FCM)
- 🗃️ **Media Repository** for storing and retrieving documents/media files
- 🔧 **Clean Architecture** with separation of models, services, repositories, and UI

---

## 📁 Project Structure

```
lib/
├── main.dart                  # Application entry point
├── firebase_options.dart      # Firebase configuration generated via FlutterFire CLI
├── data/                      # Repositories for data management
│   ├── AuthRepository.dart
│   ├── internships_repository.dart
│   ├── jobs_repository.dart
│   ├── media_repository.dart
│   ├── notification_repository.dart
│   ├── ProfileRepository.dart
│   └── applied_positions_repository.dart
├── model/                     # Data models
│   ├── AppliedPositions.dart
│   ├── Internship.dart
│   ├── Job.dart
│   ├── Notification.dart
│   └── profile.dart
├── services/                  # Backend and utility services
│   └── fcm_service.dart
└── ui/                        # UI screens and components (not shown here)
```

---

## 🚀 Getting Started

### Prerequisites

Ensure you have the following installed:
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Dart SDK](https://dart.dev/get-dart) (usually included with Flutter)
- A Firebase project with Authentication, Firestore, Cloud Messaging, and Storage enabled

### Installation

1. **Clone the Repository**
   ```bash
   git clone https://github.com/yourusername/job-portal-app.git
   cd job-portal-app
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Use the [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/) to generate `firebase_options.dart`
   - Add `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS)

4. **Run the App**
   ```bash
   flutter run
   ```

---

## 🔐 Firebase Setup Guide

1. Go to [Firebase Console](https://console.firebase.google.com/) and create a new project.
2. Add Android/iOS apps to the Firebase project.
3. Enable Authentication method (Email/Password, Google Sign-In, etc.)
4. Create Firestore database and define your data models.
5. Set up Firebase Cloud Messaging and Firebase Storage.
6. Download the `google-services.json` and/or `GoogleService-Info.plist` and place them in the appropriate directories.

---

## 🛠️ Built With

- **Flutter** – UI Toolkit for natively compiled apps
- **Firebase** – BaaS for Auth, Firestore, FCM, Storage
- **Dart** – Programming language optimized for UI
- **MVC Architecture** – Separation of concerns for scalability

---

## 📸 Screenshots

![image](https://github.com/user-attachments/assets/456f291c-93eb-4e63-87fc-c438e2f485df)


---

## 🤝 Contributing

Contributions are welcome and appreciated! To contribute:

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 📬 Contact

Maintainer: Danish Riasat
GitHub: [DanishR07](https://github.com/DanishR07)  
Email: danishriasat792@gmail.com
