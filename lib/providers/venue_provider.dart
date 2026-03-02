import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/venue.dart';
import '../services/firestore_service.dart';

class VenueProvider with ChangeNotifier {
  List<Venue> _venues = [];
  List<Venue> _favoriteVenues = [];
  List<String> _favoriteVenueIds = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isLoadingFavorites = false;
  bool _hasMoreData = true;
  String? _error;
  String? _searchQuery;
  String? _selectedCategory;
  DocumentSnapshot? _lastDocument;

  List<Venue> get venues => _venues;
  List<Venue> get favoriteVenues => _favoriteVenues;
  List<String> get favoriteVenueIds => _favoriteVenueIds;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isLoadingFavorites => _isLoadingFavorites;
  bool get hasMoreData => _hasMoreData;
  String? get error => _error;
  String? get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;

  Future<void> loadVenues({String? category, bool refresh = false}) async {
    try {
      if (refresh) {
        _venues.clear();
        _lastDocument = null;
        _hasMoreData = true;
        notifyListeners();
      }

      if (!_hasMoreData && !refresh) return;

      _isLoading = refresh;
      _isLoadingMore = !refresh;
      _error = null;
      _selectedCategory = category;
      notifyListeners();

      final result = await FirestoreService.getVenuesWithPagination(
        category: category,
        limit: 10,
        lastDocument: _lastDocument,
      );

      if (refresh) {
        _venues = result['venues'];
      } else {
        _venues.addAll(result['venues']);
      }

      _lastDocument = result['lastDocument'];
      _hasMoreData = result['hasMore'];

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadFavoriteVenues(String userId) async {
    try {
      _isLoadingFavorites = true;
      _error = null;
      notifyListeners();

      _favoriteVenues = await FirestoreService.getFavoriteVenues(userId);
      _favoriteVenueIds = _favoriteVenues.map((venue) => venue.id).toList();

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingFavorites = false;
      notifyListeners();
    }
  }

  Future<void> searchVenues(String query) async {
    try {
      _isLoading = true;
      _error = null;
      _searchQuery = query;
      notifyListeners();

      if (query.trim().isEmpty) {
        await loadVenues(refresh: true);
        return;
      }

      _venues = await FirestoreService.searchVenues(query);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String userId, String venueId) async {
    try {
      final bool isFavorite = _favoriteVenueIds.contains(venueId);

      if (isFavorite) {
        await FirestoreService.removeFromFavorites(userId, venueId);
        _favoriteVenueIds.remove(venueId);
        _favoriteVenues.removeWhere((venue) => venue.id == venueId);
      } else {
        await FirestoreService.addToFavorites(userId, venueId);
        _favoriteVenueIds.add(venueId);
        
        // Add venue to favorites list if it exists in venues
        final venue = _venues.firstWhere(
          (v) => v.id == venueId,
          orElse: () => throw Exception('Venue not found'),
        );
        _favoriteVenues.add(venue);
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  bool isVenueFavorite(String venueId) {
    return _favoriteVenueIds.contains(venueId);
  }

  Future<void> refreshVenues() async {
    await loadVenues(
      category: _selectedCategory,
      refresh: true,
    );
  }

  Future<void> refreshFavorites(String userId) async {
    await loadFavoriteVenues(userId);
  }

  void clearSearch() {
    _searchQuery = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearFilters() {
    _selectedCategory = null;
    _searchQuery = null;
    notifyListeners();
  }

  // Get venues by category
  List<Venue> getVenuesByCategory(String category) {
    return _venues.where((venue) => venue.category == category).toList();
  }

  // Get unique categories
  List<String> get categories {
    return _venues.map((venue) => venue.category).toSet().toList();
  }
}
