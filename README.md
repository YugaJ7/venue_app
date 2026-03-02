# Venue Discovery App

A Flutter application for discovering and saving favorite venues with Firebase integration, authentication, and modern UI components.

## Features

- 🔐 **Firebase Authentication** - Google Sign-In and Email/Password authentication
- 🏢 **Venue Discovery** - Browse and search venues from Firestore
- ❤️ **Favorites System** - Save and manage favorite venues
- 🔍 **Search & Filter** - Search venues by name/description and filter by category
- 📱 **Responsive UI** - Modern Material Design 3 with shimmer effects
- 🌐 **Offline Support** - Handles network connectivity issues gracefully
- ⚡ **Optimized Performance** - Efficient Firestore queries and state management
- 🎨 **Animations** - Smooth transitions and loading animations

## Architecture

### State Management
- **Provider** - For state management across the app
- **AuthProvider** - Handles authentication state
- **VenueProvider** - Manages venue data and favorites
- **ConnectivityProvider** - Monitors network connectivity

### Firebase Structure
```
Firestore Collections:
├── venues/
│   ├── {venueId}/
│   │   ├── name: string
│   │   ├── description: string
│   │   ├── imageUrl: string
│   │   ├── rating: number
│   │   ├── address: string
│   │   ├── category: string
│   │   ├── amenities: array
│   │   ├── latitude: number
│   │   ├── longitude: number
│   │   ├── phoneNumber: string
│   │   ├── website: string
│   │   ├── searchKeywords: array
│   │   ├── createdAt: timestamp
│   │   └── updatedAt: timestamp
│   └── ...
├── users/
│   ├── {userId}/
│   │   ├── email: string
│   │   ├── displayName: string
│   │   ├── photoUrl: string
│   │   ├── favoriteVenueIds: array
│   │   ├── createdAt: timestamp
│   │   └── lastLoginAt: timestamp
│   └── ...
└── users/{userId}/favorites/
    ├── {venueId}/
    │   ├── venueId: string
    │   └── addedAt: timestamp
    └── ...
```

### Project Structure
```
lib/
├── models/
│   ├── venue.dart          # Venue data model
│   └── user.dart           # User data model
├── services/
│   ├── auth_service.dart   # Firebase Authentication
│   ├── firestore_service.dart # Firestore operations
│   └── connectivity_service.dart # Network monitoring
├── providers/
│   ├── auth_provider.dart  # Authentication state
│   ├── venue_provider.dart # Venue data state
│   └── connectivity_provider.dart # Connectivity state
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── venues/
│   │   ├── venue_list_screen.dart
│   │   └── venue_detail_screen.dart
│   ├── favorites/
│   │   └── favorites_screen.dart
│   └── main_screen.dart
├── widgets/
│   ├── venue_card.dart     # Venue card component
│   ├── loading_widget.dart # Shimmer loading effects
│   └── error_widget.dart   # Error handling widgets
└── main.dart
```

## Setup Instructions

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / Xcode
- Firebase project

### 1. Clone the Repository
```bash
git clone <repository-url>
cd venue_app
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Setup

#### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project named "venue-discovery-app"
3. Enable Authentication and Firestore Database

#### Configure Authentication
1. In Firebase Console, go to Authentication > Sign-in method
2. Enable Email/Password authentication
3. Enable Google Sign-In and configure OAuth consent screen

#### Configure Firestore
1. Go to Firestore Database
2. Create database in production mode
3. Set up security rules (see below)

#### Add Configuration Files
1. **Android**: Download `google-services.json` from Firebase Console
   - Place it in `android/app/google-services.json`

2. **iOS**: Download `GoogleService-Info.plist` from Firebase Console
   - Place it in `ios/Runner/GoogleService-Info.plist`

### 4. Firestore Security Rules
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

### 5. Add Sample Data
To populate your Firestore with sample venues, you can use the Firebase Console or create a script:

```javascript
// Sample venue document
{
  "name": "The Coffee House",
  "description": "A cozy coffee shop with excellent pastries and free WiFi",
  "imageUrl": "https://example.com/coffee-house.jpg",
  "rating": 4.5,
  "address": "123 Main Street, City, State 12345",
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

### 6. Run the App
```bash
# For Android
flutter run

# For iOS
flutter run -d ios

# For Web
flutter run -d web
```

## Dependencies

### Core Dependencies
- `firebase_core: ^3.6.0` - Firebase initialization
- `firebase_auth: ^5.3.1` - Authentication
- `cloud_firestore: ^5.4.3` - Firestore database
- `google_sign_in: ^6.2.1` - Google Sign-In

### State Management
- `provider: ^6.1.2` - State management

### UI & UX
- `shimmer: ^3.0.0` - Loading shimmer effects
- `cached_network_image: ^3.4.1` - Image caching
- `lottie: ^3.1.2` - Animations

### Utilities
- `connectivity_plus: ^6.0.5` - Network connectivity
- `shared_preferences: ^2.3.2` - Local storage
- `url_launcher: ^6.3.1` - URL handling

## Key Features Implementation

### Authentication Flow
1. User opens app → Login screen
2. User signs in with email/password or Google
3. AuthProvider manages authentication state
4. Main app with bottom navigation loads

### Venue Discovery
1. VenueListScreen loads venues from Firestore
2. Search functionality filters venues
3. Category filter for better organization
4. Infinite scroll for pagination
5. Pull-to-refresh for updates

### Favorites System
1. Users can favorite/unfavorite venues
2. Favorites stored in user's subcollection
3. FavoritesScreen shows saved venues
4. Real-time updates across screens

### Error Handling
1. Network connectivity monitoring
2. Graceful error states with retry options
3. Loading states with shimmer effects
4. Empty states with helpful messages

## Performance Optimizations

### Firestore Optimizations
- **Efficient Queries**: Use indexes for search and filtering
- **Pagination**: Limit results and implement infinite scroll
- **Caching**: Firestore client-side caching
- **Subcollections**: Use subcollections for user-specific data

### UI Optimizations
- **Image Caching**: CachedNetworkImage for efficient image loading
- **Shimmer Effects**: Better perceived performance
- **Lazy Loading**: Load content as needed
- **State Management**: Minimal rebuilds with Provider

## Troubleshooting

### Common Issues

1. **Firebase not initialized**
   - Ensure `google-services.json` and `GoogleService-Info.plist` are in correct locations
   - Check Firebase project configuration

2. **Authentication not working**
   - Verify OAuth client configuration
   - Check SHA-1 fingerprints for Android
   - Ensure authentication methods are enabled

3. **Firestore permission denied**
   - Check security rules
   - Verify user authentication status

4. **Build errors**
   - Run `flutter clean && flutter pub get`
   - Check Flutter and Dart versions
   - Verify all dependencies are compatible

### Debug Mode
Enable debug logging by setting:
```dart
// In main.dart
void main() {
  Firebase.initializeApp();
  runApp(const VenueApp());
}
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## Support

For support, email jaiswal.yuga7@gmail.com or create an issue in the repository.
