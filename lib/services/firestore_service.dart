import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/venue.dart';
import '../models/user.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collection references with optimized structure
  static const String _venuesCollection = 'venues';
  static const String _usersCollection = 'users';
  static const String _favoritesCollection = 'favorites';
  
  // Venue operations
  static Future<List<Venue>> getVenues({
    String? category,
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection(_venuesCollection)
          .orderBy('createdAt', descending: true)
          .limit(limit);
      
      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }
      
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }
      
      final QuerySnapshot snapshot = await query.get();
      
      return snapshot.docs.map((doc) {
        return Venue.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch venues: $e');
    }
  }

  // Venue operations with pagination support
  static Future<Map<String, dynamic>> getVenuesWithPagination({
    String? category,
    int limit = 10,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection(_venuesCollection)
          .orderBy('createdAt', descending: true)
          .limit(limit + 1); // Get one extra to check if there are more
      
      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }
      
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }
      
      final QuerySnapshot snapshot = await query.get();
      final List<DocumentSnapshot> docs = snapshot.docs;
      
      bool hasMore = docs.length > limit;
      if (hasMore) {
        docs.removeLast(); // Remove the extra document
      }
      
      final List<Venue> venues = docs.map((doc) {
        return Venue.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      
      return {
        'venues': venues,
        'lastDocument': docs.isNotEmpty ? docs.last : null,
        'hasMore': hasMore,
      };
    } catch (e) {
      throw Exception('Failed to fetch venues: $e');
    }
  }
  
  static Future<Venue?> getVenueById(String venueId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(_venuesCollection)
          .doc(venueId)
          .get();
      
      if (doc.exists) {
        return Venue.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch venue: $e');
    }
  }
  
  static Future<List<Venue>> searchVenues(String searchTerm) async {
    try {
      // Using array-contains for partial matching on name and description
      final QuerySnapshot snapshot = await _firestore
          .collection(_venuesCollection)
          .where('name', isEqualTo: searchTerm)
          //.where('searchKeywords', arrayContains: searchTerm.toLowerCase())
          .limit(20)
          .get();
      
      return snapshot.docs.map((doc) {
        return Venue.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search venues: $e');
    }
  }
  
  // User operations
  static Future<void> createUser(AppUser user) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .set(user.toMap());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }
  
  static Future<AppUser?> getUser(String uid) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .get();
      
      if (doc.exists) {
        return AppUser.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch user: $e');
    }
  }
  
  static Future<void> updateUser(AppUser user) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .update(user.toMap());
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }
  
  // Favorites operations - using subcollection for better performance
  static Future<void> addToFavorites(String userId, String venueId) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_favoritesCollection)
          .doc(venueId)
          .set({
        'venueId': venueId,
        'addedAt': FieldValue.serverTimestamp(),
      });
      
      // Also update the user's favoriteVenueIds array
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .update({
        'favoriteVenueIds': FieldValue.arrayUnion([venueId]),
      });
    } catch (e) {
      throw Exception('Failed to add to favorites: $e');
    }
  }
  
  static Future<void> removeFromFavorites(String userId, String venueId) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_favoritesCollection)
          .doc(venueId)
          .delete();
      
      // Also update the user's favoriteVenueIds array
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .update({
        'favoriteVenueIds': FieldValue.arrayRemove([venueId]),
      });
    } catch (e) {
      throw Exception('Failed to remove from favorites: $e');
    }
  }
  
  static Future<List<String>> getUserFavorites(String userId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_favoritesCollection)
          .get();
      
      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      throw Exception('Failed to fetch user favorites: $e');
    }
  }
  
  static Future<List<Venue>> getFavoriteVenues(String userId) async {
    try {
      final List<String> favoriteIds = await getUserFavorites(userId);
      
      if (favoriteIds.isEmpty) return [];
      
      // Batch fetch venues by IDs
      final List<Future<DocumentSnapshot>> futures = favoriteIds
          .map((id) => _firestore.collection(_venuesCollection).doc(id).get())
          .toList();
      
      final List<DocumentSnapshot> docs = await Future.wait(futures);
      
      return docs
          .where((doc) => doc.exists)
          .map((doc) => Venue.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch favorite venues: $e');
    }
  }
  
  static Future<bool> isVenueFavorite(String userId, String venueId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_favoritesCollection)
          .doc(venueId)
          .get();
      
      return doc.exists;
    } catch (e) {
      throw Exception('Failed to check favorite status: $e');
    }
  }
  
  // Real-time listeners
  static Stream<List<Venue>> getVenuesStream({String? category}) {
    Query query = _firestore
        .collection(_venuesCollection)
        .orderBy('createdAt', descending: true)
        .limit(20);
    
    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }
    
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Venue.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
  
  static Stream<List<String>> getUserFavoritesStream(String userId) {
    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_favoritesCollection)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.id).toList();
    });
  }
}
