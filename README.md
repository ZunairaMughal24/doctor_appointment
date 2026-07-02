# Medic: Healthcare and Doctor Appointment Telehealth Platform

Medic is a comprehensive, production-ready mobile application built with Flutter, designed to bridge the gap between patients and healthcare providers. It provides a seamless interface for booking appointments, managing schedules, and facilitating real-time notifications. The project is structured using Clean Architecture principles and incorporates advanced features such as on-device AI-powered image validation, robust concurrency control for slot booking, and a hybrid multi-cloud infrastructure.

## Key Features

- **Dual-Role Membership Model**: Seamlessly accommodates both Patient and Doctor workflows under a unified codebase. Patients can search, book, and rate providers, while Doctors can manage their weekly schedules, accept/cancel requests, and update their practice profile.
- **On-Device AI Photo Validation**: Utilizes the Google ML Kit Face Detection API and raw pixel analysis to validate doctor profile photos. The system ensures that uploads meet professional requirements, checking for face presence, centering, proper head pose (yaw, pitch, roll), and plain, bright background uniformity.
- **Concurrency-Safe Slot Booking**: Employs Cloud Firestore transaction-based locking. Deterministic document IDs prevent race conditions and double-booking in a high-concurrency environment.
- **Atomic Rating & Review Aggregations**: Features transactional score computations that update doctor ratings. Reviews and running averages are updated atomically upon appointment completion.
- **Event-Driven Notifications Hub**: Distributes real-time alerts (e.g., booked requests, confirmations, cancellations, and daily reminders) dynamically mapped to user roles.
- **Hybrid Cloud Data Layer**: Combines Firebase Authentication and Cloud Firestore for authentication and structured document databases with Supabase Storage for secure, scalable profile-photo hosting.

## Architecture and Design Patterns

The application is built strictly around Clean Architecture guidelines, separating the codebase into distinct layers to optimize testability, modularity, and maintainability.

```
                  ┌──────────────────────────────────────────────┐
                  │                 Presentation                 │
                  │   - Flutter Widgets / Screens                 │
                  │   - BLoC & Cubits (State Management)         │
                  └──────────────────────┬───────────────────────┘
                                         │
                                         ▼
                  ┌──────────────────────────────────────────────┐
                  │                    Domain                    │
                  │   - Entities (Business Models)               │
                  │   - Use Cases (Application Logic)            │
                  │   - Repository Interfaces (Contracts)        │
                  └──────────────────────┬───────────────────────┘
                                         │
                                         ▼
                  ┌──────────────────────────────────────────────┐
                  │                     Data                     │
                  │   - Models (JSON Serialization & DTOs)       │
                  │   - Data Sources (Remote APIs / Firestore)   │
                  │   - Repository Implementations               │
                  └──────────────────────────────────────────────┘
```

### Architectural Decisions
- **State Management**: Implemented using `flutter_bloc` and `bloc_concurrency`. Blocs decouple the presentation logic from business use cases.
- **Dependency Injection**: Orchestrated via `get_it` for lazy-singleton registration of data sources, repositories, use cases, and factories for blocs.
- **Declarative Navigation**: Managed using `go_router` with shell routes to host persistent bottom navigation bars.
- **Functional Error Handling**: Leverages the `dartz` library to return functional `Either<Failure, Success>` types from the repository layer, avoiding unhandled runtime exceptions.

### Directory Layout
```
lib/
├── core/
│   ├── config/       # Configuration logic (e.g., Supabase setup)
│   ├── constants/    # Theme constants, typography, and color palettes
│   ├── di/           # Dependency injection container (GetIt)
│   ├── errors/       # Exception and Failure classifications
│   ├── router/       # GoRouter path mappings and route definitions
│   ├── services/     # Core services (Image Validation, etc.)
│   ├── theme/        # Base Material 3 colors and ThemeData configs
│   ├── usecases/     # Domain use case abstractions
│   ├── utils/        # Generic developer helpers
│   └── Widgets/      # Reusable UI widgets shared globally
├── features/
│   ├── appointments/ # Appointment booking, slot locking, and reviews
│   ├── auth/         # Login, registration, role toggling, and profile management
│   ├── doctors/      # Provider profiles, specialized search, and seed data
│   ├── notifications/# Real-time hub notifications and reminders
│   └── onboarding/   # Onboarding pager and splash introductions
├── Screens/          # Reserved folder for root pages (unused in favour of feature pages)
└── main.dart         # Main entry point and initialization
```

---

## Technical Implementations

### On-Device AI Photo Validation Pipeline
Located in [image_validation_service.dart](file:///f:/zunaira-work/Flutter-Projects/doctor_appointment/lib/core/services/image_validation_service.dart), the verification pipeline enforces professional profile criteria before uploading to Supabase:
1. **Face Count Verification**: Uses `FaceDetector` with `accurate` performance mode. The photo must contain exactly one face.
2. **Face Sizing**: Calculates the bounding box area relative to image dimensions. A face must cover at least 7% of the image to ensure clear visibility.
3. **Face Centering**: Computes offsets of the bounding box center relative to the absolute image center. The horizontal offset must not exceed 22% and the vertical offset must not exceed 25%.
4. **Orientation and Head Pose**: Evaluates Euler angles:
   - **Yaw** (head rotation left/right): Must be <= 15 degrees.
   - **Pitch** (head tilt up/down): Must be <= 15 degrees.
   - **Roll** (head tilt sideways): Must be <= 12 degrees.
5. **Background Luminosity Analysis**: Samples 18 distinct coordinate pixels across the top edge and upper margins (areas above the shoulders). It computes the relative luminance of each sample using:
   `Luminance = 0.299 * R + 0.587 * G + 0.114 * B`
   At least 70% of the sampled points must have a luminance value greater than 170 (out of 255) to guarantee a plain, light background.

### Concurrency-Safe Transactional Booking
To prevent two patients from booking the same doctor for the same time slot, the booking pipeline in [appointment_remote_data_source.dart](file:///f:/zunaira-work/Flutter-Projects/doctor_appointment/lib/features/appointments/data/datasources/appointment_remote_data_source.dart) uses Firestore transactions:
1. **Deterministic Document ID**: Creates a unique document ID for the slot:
   `Slot ID = doctorID_date_time` (with special characters like '/' and ':' replaced by hyphen/dash separators).
2. **Pre-Write Read Isolation**: Inside the transaction, the app reads the `booked_slots/{Slot ID}` document. If it exists, the transaction aborts and throws a custom exception, preventing the booking.
3. **Atomic Commit**: If the slot is free, the transaction simultaneously:
   - Creates the appointment document in `appointments`.
   - Creates the lock document in `booked_slots`.
   - Dispatches a real-time notification document to the target doctor.

---

## Database Architecture and Security Policies

### Database Collection Schema

#### 1. `users`
Represents the base user records for authentication and role representation.
- `uid`: String (Primary Key)
- `name`: String
- `email`: String
- `role`: String (e.g., "patient", "doctor")
- `currentRole`: String (active runtime role)

#### 2. `doctors`
Stores professional profiles for registered healthcare providers.
- `uid`: String (Primary Key)
- `name`: String
- `email`: String
- `speciality`: String
- `experience`: String
- `number`: String (contact number)
- `location`: String
- `availability`: String
- `services`: String
- `description`: String
- `rating`: Double (average score)
- `rating_count`: Integer
- `rating_total`: Double
- `schedule`: Map (weekly availability days/hours)

#### 3. `appointments`
Details individual bookings between patients and doctors.
- `id`: String (Primary Key)
- `appointment_by_id`: String (Patient User ID)
- `appointment_by_name`: String
- `appointment_with_id`: String (Doctor User ID)
- `appointment_with_name`: String
- `appointment_date`: String
- `appointment_time`: String
- `status`: String ("pending", "confirmed", "completed", "cancelled")
- `rating`: Integer (optional)
- `rating_comment`: String (optional)

#### 4. `booked_slots`
Maintains concurrency locks to prevent double-booking.
- `id`: String (Format: `{doctor_id}_{date}_{time}`)
- `doctor_id`: String
- `date`: String
- `time`: String
- `appointment_id`: String

#### 5. `notifications`
Supports real-time alerts.
- `id`: String (Primary Key)
- `user_id`: String (Recipient User ID)
- `title`: String
- `body`: String
- `type`: String ("booked", "confirmed", "completed", "cancelled", "reminder")
- `appointment_id`: String
- `read`: Boolean
- `created_at`: Timestamp

### Firestore Security Rules
The database operates under standard development rules configured in [firestore.rules](file:///f:/zunaira-work/Flutter-Projects/doctor_appointment/firestore.rules):
- **Users**: Signed-in users can read profiles; updates/writes are restricted to the owner (`request.auth.uid == uid`).
- **Doctors**: Globally readable by any client. Writes allowed by authenticated users (allowing doctors to update profiles and app self-healing scripts to seed initial records).
- **Appointments & Booked Slots**: Accessible (read/write) by signed-in users.
- **Notifications**: Readable and deletable only by the recipient (`resource.data.user_id == request.auth.uid`). Writes are open to any authenticated user (e.g., patient booking an appointment can trigger a notification on the doctor's feed).

---

## Setup and Installation Guide

### Prerequisites
- Flutter SDK (version `>=3.0.0 <4.0.0`)
- Dart SDK
- Android SDK / Xcode (for mobile compilation)
- Firebase Project Console Access
- Supabase Project Console Access

### Installation
1. Clone the repository and navigate to the project directory:
   ```bash
   git clone <repository-url>
   cd doctor_appointment
   ```
2. Retrieve the Flutter packages:
   ```bash
   flutter pub get
   ```

### Configuration
1. **Firebase**:
   - Create a project on the [Firebase Console](https://console.firebase.google.com/).
   - Add Android and iOS applications to your Firebase project.
   - Download and place `google-services.json` in `android/app/` and `GoogleService-Info.plist` in `ios/Runner/`.
   - Enable **Email/Password** authentication in the Firebase Auth settings.
   - Deploy the [firestore.rules](file:///f:/zunaira-work/Flutter-Projects/doctor_appointment/firestore.rules) file.

2. **Supabase**:
   - Create a project on [Supabase](https://supabase.com/).
   - Go to **Storage**, create a new bucket named `profile-pictures`, and mark it **Public**.
   - Copy `.env.example` to a new `.env` file:
     ```bash
     cp .env.example .env
     ```
   - Update the `.env` file with your project's credentials:
     ```env
     SUPABASE_URL=https://YOUR_PROJECT_ID.supabase.co
     SUPABASE_ANON_KEY=YOUR_ANON_OR_PUBLISHABLE_KEY
     ```

### Compilation & Running
- **Debug Mode**:
  ```bash
  flutter run
  ```
- **Run Unit Tests**:
  ```bash
  flutter test
  ```
- **Release Compilation**:
  - Android:
    ```bash
    flutter build apk --release
    ```
  - iOS:
    ```bash
    flutter build ipa --release
    ```
