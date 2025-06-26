# Google Sign-In Setup Guide

This guide will help you fix the Google Sign-In error: `PlatformException(sign_in_failed, com.google.android.gms.common.api.ApiException: 10)`

## 🔧 Fix Steps

### Step 1: Add SHA-1 Fingerprint to Firebase

Your app's SHA-1 fingerprint is:

```
5F:D1:52:35:E5:76:99:C8:A0:98:D0:F1:7F:55:2F:3D:63:DF:30:84
```

**To add it to Firebase:**

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (`notes-app-f79cc`)
3. Click the gear icon ⚙️ (Project Settings)
4. Scroll down to "Your apps" section
5. Find your Android app (`com.example.notes_app`)
6. Click "Add fingerprint"
7. Paste the SHA-1 fingerprint: `5F:D1:52:35:E5:76:99:C8:A0:98:D0:F1:7F:55:2F:3D:63:DF:30:84`
8. Click "Save"

### Step 2: Download Updated google-services.json

After adding the SHA-1 fingerprint:

1. In Firebase Console → Project Settings → Your apps
2. Click "Download google-services.json"
3. Replace the existing file in `android/app/google-services.json`

### Step 3: Enable Google Sign-In in Firebase

1. Go to Firebase Console → Authentication
2. Click "Sign-in method" tab
3. Find "Google" in the list
4. Click "Enable"
5. Add your support email
6. Click "Save"

### Step 4: Configure OAuth Consent Screen (if needed)

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your Firebase project
3. Navigate to "APIs & Services" → "OAuth consent screen"
4. Configure the consent screen:
   - User Type: External
   - App name: "Notes App"
   - User support email: Your email
   - Developer contact information: Your email
5. Add scopes:
   - `.../auth/userinfo.email`
   - `.../auth/userinfo.profile`
6. Add test users (your email address)
7. Save and continue

### Step 5: Enable Google Sign-In API

1. In Google Cloud Console → "APIs & Services" → "Library"
2. Search for "Google Sign-In API"
3. Click on it and click "Enable"

### Step 6: Clean and Rebuild

```bash
flutter clean
flutter pub get
flutter run
```

## 🔍 Troubleshooting

### Still Getting Error 10?

1. **Check SHA-1 Fingerprint**: Make sure you added the correct SHA-1
2. **Wait for Propagation**: Changes can take up to 10 minutes to propagate
3. **Check Package Name**: Ensure your package name matches in Firebase
4. **Verify google-services.json**: Make sure it's the latest version

### Error Code Meanings

- **Error 10**: Developer error (usually SHA-1 mismatch or API not enabled)
- **Error 12501**: User cancelled the sign-in
- **Error 12500**: Sign-in failed (check configuration)

### Alternative: Test with Email/Password

If Google Sign-In continues to have issues, you can still use email/password authentication while troubleshooting.

## 📱 Testing

1. **Test Email/Password**: Try creating an account with email/password first
2. **Test Google Sign-In**: After completing the setup, try Google Sign-In
3. **Check Logs**: Look for detailed error messages in the console

## 🔒 Security Notes

- The SHA-1 fingerprint is for debug builds
- For production, you'll need to add the release SHA-1 fingerprint
- Keep your google-services.json file secure and don't commit it to public repositories

## 📞 Support

If you continue to have issues:

1. Check the [Firebase Documentation](https://firebase.google.com/docs/auth/android/google-signin)
2. Verify all steps in this guide
3. Check Firebase Console for any error messages
4. Ensure your Google account has the necessary permissions
