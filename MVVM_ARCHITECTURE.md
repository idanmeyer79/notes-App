# MVVM Architecture Implementation

This Flutter app follows the MVVM (Model-View-ViewModel) design pattern for better separation of concerns, testability, and maintainability.

## Architecture Overview

```
lib/
├── models/           # Data models (M in MVVM)
├── views/           # UI components (V in MVVM)
├── viewmodels/      # Business logic and state management (VM in MVVM)
├── services/        # Data access layer
├── repositories/    # Abstraction layer for data operations
└── widgets/         # Reusable UI components
```

## Components

### 1. Models (`lib/models/`)

- **Note**: Data model representing a note with all its properties
- Contains data validation and serialization logic
- Pure data classes with no business logic

### 2. Views (`lib/views/`)

- **MyHomePage**: Main screen displaying the list/map of notes
- **NoteScreen**: Screen for creating and editing notes
- **NoteListView**: Widget for displaying notes in list format
- **NoteMapView**: Widget for displaying notes on a map
- Views are responsible only for UI rendering and user interaction
- No business logic or data manipulation

### 3. ViewModels (`lib/viewmodels/`)

- **BaseViewModel**: Abstract base class providing common functionality
  - State management (loading, success, error)
  - Error handling
  - Async operation wrapper
- **HomeViewModel**: Manages the home screen state
  - Note list management
  - View mode switching (list/map)
  - User information
- **NoteViewModel**: Manages note creation and editing
  - Form validation
  - Note CRUD operations
  - Form state management
  - Location capture and management

### 4. Services (`lib/services/`)

- **NoteService**: Handles direct data operations
  - Firebase Firestore interactions
  - Data transformation
  - Error handling for data operations
- **LocationService**: Handles location operations
  - Current location capture using geolocator
  - Location permissions management
  - Distance calculations
  - Error handling for location operations

### 5. Repositories (`lib/repositories/`)

- **NoteRepository**: Abstraction layer for data access
  - Provides clean interface for ViewModels
  - Can be easily mocked for testing
  - Handles data caching if needed

## Key MVVM Principles Implemented

### 1. Separation of Concerns

- **Models**: Pure data structures
- **Views**: UI only, no business logic
- **ViewModels**: Business logic and state management
- **Services**: Data access and external API calls
- **Repositories**: Data abstraction layer

### 2. Data Binding

- Views observe ViewModels using `Consumer<ViewModel>`
- ViewModels notify Views of changes using `notifyListeners()`
- Reactive UI updates based on state changes

### 3. State Management

- Centralized state management in ViewModels
- Clear state transitions (idle → loading → success/error)
- Error handling and user feedback

### 4. Testability

- ViewModels can be easily unit tested
- Services and repositories can be mocked
- Views are isolated from business logic

### 5. Single Responsibility Principle

- Each ViewModel handles one specific feature
- Services handle one type of data operation
- Views handle one screen's UI

## Location Functionality

### Features

- **Automatic Location Capture**: When creating a new note, the app automatically captures the user's current location
- **Manual Location Capture**: Users can manually capture location using the "Capture Location" button
- **Location Display**: Shows captured coordinates in the note creation screen
- **Location Persistence**: Location data is stored with each note in Firestore
- **Map Integration**: Notes with location data can be displayed on the map view

### Implementation Details

- Uses the `geolocator` package for location services
- Handles location permissions gracefully
- Provides user feedback for location capture success/failure
- Location capture doesn't block note creation if it fails
- Location data is optional - notes can be created without location

### Permissions

- **Android**: ACCESS_FINE_LOCATION, ACCESS_COARSE_LOCATION, ACCESS_BACKGROUND_LOCATION
- **iOS**: NSLocationWhenInUseUsageDescription, NSLocationAlwaysAndWhenInUseUsageDescription

## Usage Examples

### Creating a New Note with Location

1. User taps FAB → View (NoteScreen) opens
2. ViewModel (NoteViewModel) is initialized
3. User enters data → ViewModel updates state
4. User taps "Capture Location" → ViewModel calls LocationService
5. LocationService requests permissions and captures location
6. Location coordinates are displayed in the UI
7. User saves → ViewModel calls Repository with location data
8. Repository calls Service → Service calls Firebase
9. Success → ViewModel updates state → View shows success message

### Loading Notes

1. App starts → HomeViewModel initializes
2. HomeViewModel calls Repository
3. Repository calls Service → Service fetches from Firebase
4. Data flows back: Service → Repository → ViewModel → View
5. View displays notes in list/map format

## Benefits of This Architecture

1. **Maintainability**: Clear separation makes code easier to understand and modify
2. **Testability**: Each layer can be tested independently
3. **Scalability**: Easy to add new features without affecting existing code
4. **Reusability**: Components can be reused across different screens
5. **Error Handling**: Centralized error handling and user feedback
6. **State Management**: Predictable state transitions and UI updates
7. **Location Integration**: Seamless location capture and management

## Best Practices Followed

1. **Dependency Injection**: Using Provider for ViewModel injection
2. **Async Operations**: Proper handling of async operations with loading states
3. **Error Handling**: Comprehensive error handling at each layer
4. **Validation**: Input validation in ViewModels
5. **Memory Management**: Proper disposal of resources
6. **Type Safety**: Strong typing throughout the application
7. **Permission Handling**: Graceful handling of location permissions
8. **User Feedback**: Clear feedback for location operations
