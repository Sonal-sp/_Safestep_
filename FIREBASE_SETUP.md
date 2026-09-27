# SafeStep — Firebase Setup

## 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **Add project** → Name it "SafeStep" (or your choice)
3. Enable Google Analytics (optional)
4. Create the project

## 2. Add Android App

1. In Project Overview → **Add app** → Android
2. **Android package name**: `com.safestep.safestep` (must match `applicationId` in `android/app/build.gradle.kts`)
3. **App nickname**: SafeStep (optional)
4. **Debug signing certificate SHA-1** (optional for dev): Run:
   ```
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android
   ```
5. Download `google-services.json` and place it in:
   ```
   safestep/android/app/google-services.json
   ```

## 3. Add Web App (for Chrome/web runs)

1. In Project Overview → **Add app** → Web (`</>`)
2. **App nickname**: SafeStep Web (optional)
3. Register the app
4. Run from project root: `flutterfire configure`
5. Select your Firebase project (e.g. safe-step-44383)
6. Select **Web** when asked which platforms to configure
7. This regenerates `lib/firebase_options.dart` with the correct web `appId`

## 4. Add iOS App (for iOS builds)

1. In Project Overview → **Add app** → iOS
2. **iOS bundle ID**: `com.safestep.safestep`
3. Download `GoogleService-Info.plist` and add to `ios/Runner/` in Xcode

## 5. Enable Firebase Services

### Authentication
- **Build** → **Authentication** → **Get started**
- Enable **Email/Password** sign-in method

### Cloud Firestore
- **Build** → **Firestore Database** → **Create database**
- Start in **test mode** for development (or production with rules)
- Choose a region

### Cloud Messaging (FCM)
- Automatically enabled with Firebase
- For production: Add server key / service account for backend notifications

## 6. Firestore Security Rules (recommended)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /profiles/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /medications/{docId} {
      allow read, write: if request.auth != null && resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
    }
    match /medication_logs/{docId} {
      allow read, write: if request.auth != null && resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
    }
    match /medical_history/{docId} {
      allow read, write: if request.auth != null && resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
    }
    match /emergency_contacts/{docId} {
      allow read, write: if request.auth != null && resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
    }
    match /sos_alerts/{docId} {
      allow read, write: if request.auth != null && resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
    }
  }
}
```

## 7. Deploy Firestore Indexes (if needed)

If you see index errors in the console:

```
firebase deploy --only firestore:indexes
```

Or create indexes manually in Firebase Console → Firestore → Indexes.

## 8. Run the App

```bash
cd safestep
flutter pub get
flutter run
```

---

**Note:** Ensure `google-services.json` is in `android/app/` before building. The app will crash on startup if Firebase is not configured.
