# Authentication Setup

This app uses Firebase Authentication for user management with the following features:

## Features

- **Email/Password Authentication**: Users can sign up and sign in with email and password
- **Google Sign-In**: Users can sign in using their Google account
- **Password Reset**: Users can reset their password via email
- **Persistent Login**: Users remain logged in between app sessions
- **Automatic Navigation**: App automatically navigates between login and home based on authentication state

## Firebase Configuration

### 1. Firebase Project Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select an existing one
3. Enable Authentication in the Firebase console

### 2. Authentication Methods

Enable the following authentication methods in Firebase Console:

#### Email/Password

1. Go to Authentication > Sign-in method
2. Enable "Email/Password"
3. Optionally enable "Email link (passwordless sign-in)"

#### Google Sign-In

1. Go to Authentication > Sign-in method
2. Enable "Google"
3. Configure OAuth consent screen if needed
4. Add your app's SHA-1 fingerprint for Android

### 3. Android Configuration

For Google Sign-In to work on Android, you need to add your app's SHA-1 fingerprint:

1. Get your app's SHA-1 fingerprint:

   ```bash
   cd android && ./gradlew signingReport
   ```

2. Add the SHA-1 fingerprint to your Firebase project:
   - Go to Project Settings > Your Apps > Android app
   - Add the SHA-1 fingerprint

### 4. iOS Configuration

For Google Sign-In to work on iOS:

1. Download the `GoogleService-Info.plist` file from Firebase Console
2. Add it to your iOS project (Runner/Runner/GoogleService-Info.plist)
3. Update your iOS project's URL schemes in Xcode

## App Structure

### Authentication Files

- `lib/services/auth_service.dart` - Firebase authentication service
- `lib/viewmodels/auth_viewmodel.dart` - Authentication state management
- `lib/pages/login_page.dart` - Login screen
- `lib/pages/signup_page.dart` - Signup screen
- `lib/pages/forgot_password_page.dart` - Password reset screen
- `lib/widgets/auth_wrapper.dart` - Authentication state wrapper
- `lib/widgets/splash_screen.dart` - Loading screen

### Key Features

1. **Automatic State Management**: The app automatically handles authentication state changes
2. **Error Handling**: Comprehensive error messages for authentication failures
3. **Loading States**: Loading indicators during authentication operations
4. **Form Validation**: Client-side validation for email and password fields
5. **Persistent Login**: Users stay logged in until they explicitly sign out

## Usage

### Sign In

- Users can sign in with email/password or Google account
- Form validation ensures proper email format and password length
- Error messages are displayed for authentication failures

### Sign Up

- New users can create accounts with email/password
- Password confirmation ensures matching passwords
- Google sign-up is also available

### Password Reset

- Users can request password reset via email
- Success confirmation is shown after email is sent

### Sign Out

- Users can sign out from the home screen
- Confirmation dialog prevents accidental logout

## Security

- Passwords are validated on both client and server side
- Firebase handles secure password storage and authentication
- Google Sign-In uses OAuth 2.0 for secure authentication
- All authentication tokens are managed securely by Firebase

## Dependencies

The following packages are used for authentication:

```yaml
dependencies:
  firebase_auth: ^5.3.1
  google_sign_in: ^6.2.1
```

Make sure to run `flutter pub get` after adding these dependencies.
