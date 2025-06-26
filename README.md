# Notes App

A Flutter application for creating and managing notes with location support, built using the MVVM design pattern.

## Features

- **Note Management**: Create, view, and edit notes
- **Location Support**: Add location data to notes
- **Dual View Modes**:
  - List view: All notes sorted by creation date
  - Map view: Notes displayed as pins on a map
- **Firebase Integration**: Cloud Firestore for data storage
- **Image Support**: Amazon S3 integration for image storage (planned)
- **Modern UI**: Material Design 3 with beautiful animations

## Architecture

This app follows the **MVVM (Model-View-ViewModel)** design pattern:

- **Models**: Data classes representing the app's entities
- **Views**: UI components that display data and handle user interactions
- **ViewModels**: Business logic layer that manages state and data operations

## Setup Instructions

### Prerequisites

- Flutter SDK (3.7.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Firebase account
- Google Cloud Platform account (for Maps API)

### 1. Clone and Install Dependencies

```bash
git clone <repository-url>
cd notes_app
flutter pub get
```

### 2. Firebase Setup

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable Cloud Firestore in your project
3. Set up Firestore security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /notes/{noteId} {
      allow read, write: if true; // For development - add proper auth rules later
    }
  }
}
```

4. Install FlutterFire CLI:

```bash
dart pub global activate flutterfire_cli
```

5. Configure Firebase for your app:

```bash
flutterfire configure
```

6. Update `lib/firebase_options.dart` with your actual Firebase configuration

### 3. Google Maps Setup

1. Enable Google Maps API in [Google Cloud Console](https://console.cloud.google.com/)
2. Create an API key for Maps SDK for Android and iOS
3. Add the API key to your platform-specific configuration:

#### Android

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest ...>
    <application ...>
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR_API_KEY"/>
    </application>
</manifest>
```

#### iOS

Add to `ios/Runner/AppDelegate.swift`:

```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_API_KEY")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### 4. Run the App

```bash
flutter run
```

## Project Structure

```
lib/
├── models/
│   └── note.dart              # Note data model
├── viewmodels/
│   └── home_viewmodel.dart    # Home page business logic
├── widgets/
│   ├── note_list_view.dart    # List view widget
│   └── note_map_view.dart     # Map view widget
├── screens/
│   └── note_screen.dart       # Note creation/editing screen
├── firebase_options.dart      # Firebase configuration
├── home_page.dart             # Main home page
└── main.dart                  # App entry point
```

## Key Components

### Note Model

- Represents a note with title, content, creation date, and optional location data
- Includes Firestore serialization methods

### HomeViewModel

- Manages the state of the home page
- Handles data fetching from Firestore
- Controls view mode switching (list/map)
- Provides error handling and loading states

### NoteListView

- Displays notes in a scrollable list
- Shows note preview with title, content snippet, and metadata
- Handles empty state with call-to-action
- Supports pull-to-refresh

### NoteMapView

- Displays notes as pins on a Google Map
- Shows note information in marker info windows
- Handles notes without location data
- Provides map controls for navigation

## Next Steps

1. **Authentication**: Implement user authentication with Firebase Auth
2. **Note Creation/Editing**: Complete the note screen functionality
3. **Image Upload**: Integrate Amazon S3 for image storage
4. **Search**: Add note search functionality
5. **Categories**: Implement note categorization
6. **Offline Support**: Add offline data synchronization

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License.
