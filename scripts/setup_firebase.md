# Firebase Setup Guide

## Step-by-Step Firebase Configuration

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter project name: `venue-discovery-app`
4. Enable Google Analytics (optional)
5. Choose or create a Google Analytics account
6. Click "Create project"

### 2. Enable Authentication
1. In Firebase Console, go to "Authentication" > "Sign-in method"
2. Enable "Email/Password" provider
3. Enable "Google" provider
4. For Google Sign-In:
   - Add your app's SHA-1 fingerprint (Android)
   - Configure OAuth consent screen
   - Add authorized domains

### 3. Create Firestore Database
1. Go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in production mode"
4. Select a location (choose closest to your users)
5. Click "Done"

### 4. Configure Security Rules
Replace the default rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Venues are readable by all authenticated users
    match /venues/{venueId} {
      allow read: if request.auth != null;
      allow write: if false; // Only admins can write venues
    }
    
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Favorites subcollection
      match /favorites/{favoriteId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

### 5. Add Android App
1. In Firebase Console, click "Add app" > Android
2. Enter package name: `com.example.venue_app`
3. Enter app nickname: `Venue App Android`
4. Download `google-services.json`
5. Place it in `android/app/google-services.json`

### 6. Add iOS App
1. In Firebase Console, click "Add app" > iOS
2. Enter bundle ID: `com.example.venueApp`
3. Enter app nickname: `Venue App iOS`
4. Download `GoogleService-Info.plist`
5. Place it in `ios/Runner/GoogleService-Info.plist`

### 7. Get SHA-1 Fingerprint (Android)
Run this command in your project root:
```bash
cd android
./gradlew signingReport
```

Copy the SHA-1 fingerprint and add it to your Firebase project settings.

### 8. Add Sample Data
Use the Firebase Console to add sample venues:

1. Go to Firestore Database
2. Click "Start collection"
3. Collection ID: `venues`
4. Add documents with the following structure:

```json
{
  "name": "The Coffee House",
  "description": "A cozy coffee shop with excellent pastries and free WiFi",
  "imageUrl": "https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=800",
  "rating": 4.5,
  "address": "123 Main Street, New York, NY 10001",
  "category": "Restaurant",
  "amenities": ["WiFi", "Outdoor Seating", "Pet Friendly"],
  "latitude": 40.7128,
  "longitude": -74.0060,
  "phoneNumber": "+1-555-0123",
  "website": "https://thecoffeehouse.com",
  "searchKeywords": ["coffee", "cafe", "pastries", "wifi", "cozy"],
  "createdAt": 1640995200000,
  "updatedAt": 1640995200000
}
```

### 9. Test the Setup
1. Run `flutter pub get`
2. Run `flutter run`
3. Test authentication and venue loading

## Troubleshooting

### Common Issues:
- **Build errors**: Make sure `google-services.json` and `GoogleService-Info.plist` are in correct locations
- **Authentication not working**: Check SHA-1 fingerprint and OAuth configuration
- **Permission denied**: Verify Firestore security rules
- **No data showing**: Check if sample data was added correctly

### Getting Help:
- Check Firebase Console for error logs
- Verify all configuration files are in place
- Ensure all dependencies are installed with `flutter pub get`
