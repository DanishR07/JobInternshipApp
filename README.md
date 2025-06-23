
# Internships & Job Portal App

A mobile application developed using **Flutter** and **Firebase** that helps users explore internships, apply for jobs, manage their profile, receive notifications, and more — all in a seamless and intuitive interface.

## Description
**Internships & Job Portal App** is a cross-platform mobile application built with Flutter and integrated with Firebase services. The primary goal of this app is to create a streamlined and user-friendly platform where students, fresh graduates, and job seekers can:

Explore job and internship opportunities,
Manage their applications,
Receive important updates and notifications,
Maintain their profiles,
And interact with companies looking for potential candidates.

This app serves both educational and professional purposes, making it a powerful prototype or production-level solution for university career centers, HR startups, or recruitment services.

It has two roles:
Admin Panel(Can add/edit/delete Jobs/Internships, Can view applications submitted by users and can update their status to send notifications to users about their applications)
User Side


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
- **MVVM Architecture** – Separation of concerns for scalability

---

## 📸 Screenshots
Welcome Screen
![image](https://github.com/user-attachments/assets/456f291c-93eb-4e63-87fc-c438e2f485df)
Login Page
![image](https://github.com/user-attachments/assets/720d0de8-4bfe-4434-9b35-93671db32d6f)
Signup Page
![image](https://github.com/user-attachments/assets/6988b641-eaed-4e37-a941-fcc4074155d8)
User Home Page
![image](https://github.com/user-attachments/assets/b9d67060-21e0-4daf-a675-ce95a60b06cd)
![image](https://github.com/user-attachments/assets/184f8c6f-a642-49a7-a981-f24bd3461cd2)
![image](https://github.com/user-attachments/assets/9f398986-b26b-47d0-9446-8b905fce69f5)
Admin Side
![image](https://github.com/user-attachments/assets/3cecf0d8-d754-4fd5-9ab1-02815146468b)
![image](https://github.com/user-attachments/assets/09ff38d8-ba9d-4068-9424-2154a1e49bea)
![image](https://github.com/user-attachments/assets/73d42fb3-4f9a-4e8c-9da3-259650e0e40a)
![image](https://github.com/user-attachments/assets/a99a4a90-74e5-4c26-81a4-f29191b5986f)
![image](https://github.com/user-attachments/assets/d1bd299a-5fc4-4ece-81b4-88b6ac7a5ead)

Guest Page
![image](https://github.com/user-attachments/assets/d972d850-31be-4c1c-930e-8ed9e548c42e)
![image](https://github.com/user-attachments/assets/240540d7-8ccd-4c86-80db-ffa9652308a5)
Jobs Page
![image](https://github.com/user-attachments/assets/ec8b9d69-f7ae-471a-8a27-064180506a8d)
Internships Page
![image](https://github.com/user-attachments/assets/93a898cf-dd9c-4f00-8dbf-85906161b926)
Applied Positions Page
![image](https://github.com/user-attachments/assets/97052735-5629-4fe2-bbef-a01a2f7d8629)
Profile Page
![image](https://github.com/user-attachments/assets/35abca75-222b-46c2-964a-9a00b427a528)
Notifications Page
![image](https://github.com/user-attachments/assets/2ed2b5e0-399a-4d97-91ef-dbc89da7fc68)
![image](https://github.com/user-attachments/assets/87c0f3ef-b171-43fe-8156-bcaedac066cc)

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
