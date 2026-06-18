<div align="center">

# 🏥 HealthRootz

**A Comprehensive Healthcare Flutter Application for Doctors & Patients**

[![Flutter](https://img.shields.io/badge/Flutter-3.10-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0-0175C2?logo=dart)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Integrated-FFCA28?logo=firebase)](https://firebase.google.com)
[![Architecture](https://img.shields.io/badge/Architecture-Feature--Based-success)](#)
[![State Management](https://img.shields.io/badge/State_Management-Bloc/Cubit-blue)](#)

*HealthRootz bridges the gap between healthcare providers and patients, offering real-time consultations, AI medical assistance, appointment management, health tracking, and smart device integrations in a single, unified platform.*

</div>

---

## 📖 Table of Contents
- [Project Overview](#-project-overview)
- [Key Features](#-key-features)
- [Technologies & Packages](#-technologies--packages)
- [Project Architecture](#-project-architecture)
- [Project Structure](#-project-structure)
- [API & Networking](#-api--networking)
- [State Management](#-state-management)
- [Code Highlights & Best Practices](#-code-highlights--best-practices)
- [Environment Configuration](#-environment-configuration)
- [Setup & Installation](#-setup--installation)
- [Future Improvements](#-future-improvements)
---

## 🚀 Project Overview

**HealthRootz** is a dual-interface mobile application designed to cater to both **Patients** and **Doctors**. 
- **For Patients:** It acts as a personal health companion, allowing them to track vitals, connect with IoT medical devices, schedule appointments, communicate with doctors, and get preliminary guidance from an AI-powered medical assistant.
- **For Doctors:** It provides a comprehensive dashboard to monitor patient reports, manage appointments, respond to alerts, and handle patient communications efficiently.

---

## ✨ Key Features

### 🧑‍⚕️ Patient Module
- **AI Health Chat:** Get initial guidance and medical information using Google's Generative AI.
- **Vitals Tracking & Device Integration:** Monitor health metrics and connect smart medical devices for real-time data sync.
- **Appointment Management:** Book, reschedule, and track appointments with healthcare providers.
- **Medical History:** Maintain a digital record of past consultations, prescriptions, and health events.
- **Direct Chat:** Secure real-time messaging with doctors.
- **Alerts System:** Receive critical notifications regarding medications, appointments, or vital anomalies.

### 🩺 Doctor Module
- **Dashboard & Analytics:** View key statistics and overviews of patient loads and upcoming tasks.
- **Patient Management:** Access detailed patient profiles, medical histories, and active notes.
- **Reports Management:** Generate, export, and review patient medical reports (supports PDF generation).
- **Appointment Scheduling:** View slots and manage daily patient queues.
- **Real-time Communication:** Direct secure chat with registered patients.

### ⚙️ General System Features
- **Role-based Authentication:** Secure login using custom REST APIs and Firebase Auth.
- **Localization:** Multi-language support out of the box (English & others).
- **Theming:** Seamless Light and Dark mode transition based on user preference.

---

## 🛠️ Technologies & Packages

The project utilizes a robust stack of modern technologies and industry-standard packages:

### Core Technologies
- **Framework:** Flutter (SDK ^3.10.7)
- **Language:** Dart
- **Backend Services:** Firebase (Auth, Core, Storage, Firestore) & Custom REST API Node.js/Python (via endpoints).
- **AI Engine:** Google Generative AI (`google_generative_ai: ^0.4.3`)

### Important Packages (`pubspec.yaml`)
| Package | Purpose |
|---------|---------|
| `flutter_bloc` | Core state management utilizing the Bloc and Cubit patterns. |
| `dio` | High-performance HTTP client for REST API integration. |
| `dartz` | Functional programming paradigm for robust error handling (`Either` type). |
| `shared_preferences` | Local storage for caching user sessions, themes, and language preferences. |
| `fl_chart` | Rendering dynamic and interactive health metric graphs. |
| `pdf` & `printing` | Generating medical reports in PDF format and native printing support. |
| `intl` & `flutter_localizations` | Handling internationalization and date formatting. |
| `firebase_auth` & `cloud_firestore` | Authentication and real-time database capabilities. |
| `video_player` & `gif_view` | Rendering rich media within the app. |

---

## 🏗️ Project Architecture

HealthRootz follows a **Feature-Based MVVM Architecture**, ensuring high scalability, separation of concerns, and ease of maintenance. The app is broadly divided into logical domains:

1. **Core Layer:** Contains essential app-wide configurations, network clients (`Dio`), API constants, abstract models, routing, and global state (Theme, Language, Auth).
2. **Feature Layer (Patient & Doctor):** Each feature (e.g., Home, Chat, Appointments) is encapsulated in its own directory containing its specific UI, Cubit/Bloc, and local models.
3. **Shared Layer:** Houses reusable UI components (custom buttons, text fields, cards) to maintain design consistency and reduce code duplication.

---

## 📂 Project Structure

```text
lib/
├── core/
│   ├── cubit/           # Global State Management (Auth, Theme, Language)
│   ├── models/          # Shared Data Models
│   ├── network/         # API Client (Dio), API Constants, and Token Storage
│   ├── services/        # Service layers (Auth, Appointments, Reports, Devices, Vitals)
│   └── theme/           # Light/Dark Theme configurations & App Colors
├── doctor/
│   ├── doctor_layout.dart
│   └── features/        # Doctor Modules (Alert, Chat, Home, Patients, Profile, Reports)
├── patient/
│   └── features/        # Patient Modules (AI Chat, Appointments, Chat, History, Home, Vitals, Profile)
├── shared/
│   └── widgets/         # Reusable UI components
├── l10n/                # Localization files (AppLocalizations)
├── main.dart            # Application Entry Point & MultiBlocProvider Setup
└── splash.dart          # Splash Screen implementation
```

---

## 🌐 API & Networking

Networking is handled via a singleton **`ApiClient`** built on top of `Dio`.

- **Interceptors:** Used to inject Authorization tokens into headers and handle global 401/403 responses automatically.
- **API Constants:** A dedicated file (`core/network/api_constants.dart`) manages all endpoints centrally (Auth, Patients, Alerts, Appointments, Reports, Chat, Dashboard, Vitals, Devices).
- **Service Classes:** Domain-specific services (`AuthService`, `AppointmentService`, `DeviceService`) abstract the network calls and return parsed Models or standard `ApiResponse` objects.

---

## 🧠 State Management

The application heavily relies on **`flutter_bloc`**:
- **Global Cubits:** `AuthCubit`, `ThemeCubit`, and `LanguageCubit` are initialized at the root level (`main.dart`) to provide app-wide context.
- **Feature-Level Cubits:** Each specific screen or feature has its own Cubit to manage local states (Loading, Success, Failure) ensuring UI components are completely decoupled from business logic.

---

## 💎 Code Highlights & Best Practices

- **Functional Error Handling:** Utilizing `dartz` (`Either<Failure, Success>`) to gracefully handle repository responses without relying heavily on `try-catch` blocks in the UI layer.
- **Secure Token Storage:** Using `shared_preferences` securely wrapped within a `TokenStorage` utility.
- **Responsive Theming:** Dynamic resolution of themes upon cold start (`ThemeCubit.readSaved()`) avoiding UI flashes.
- **Clean API Config:** Centralized configuration (`api_config.dart`) makes switching between local, staging, and production environments effortless.

---

## ⚙️ Environment Configuration

Before running the project, make sure to configure the necessary environment variables:

1. **API Base URL:**
   Configure the host address in `lib/core/network/api_config.dart`. Ensure it points to your local Node.js/Python server or production endpoint.
2. **Firebase Setup:**
   Ensure you have configured Firebase for the project. Place the `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS) in their respective directories.

---

## 💻 Setup & Installation

### Prerequisites
- Flutter SDK `^3.10.7`
- Dart SDK
- Android Studio / VS Code
- A configured physical device or emulator.

### Installation Steps

1. **Clone the repository:**
   ```bash
   git clone https://github.com/YourUsername/HealthRootz.git
   cd HealthRootz
   ```

2. **Install Dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run Code Generation (if applicable for localization/models):**
   ```bash
   flutter gen-l10n
   ```

4. **Run the Application:**
   ```bash
   flutter run
   ```

## 🔮 Future Improvements

- **WebRTC Integration:** Introduce live video/audio consultations between patients and doctors.
- **Offline First:** Enhance local caching using Hive or Isar for an offline-first experience.
- **Wearable Sync:** Deep integration with Apple HealthKit and Google Fit APIs.
- **Advanced Analytics:** Integrate predictive AI models to analyze long-term vital trends.
---
<div align="center">
  <i>Developed with ❤️ using Flutter</i>
</div>
