import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:venue_app/widgets/error_widget.dart';
import '../../providers/venue_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../widgets/venue_card.dart';
import '../../widgets/loading_widget.dart';
import '../venues/venue_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final venueProvider = Provider.of<VenueProvider>(context, listen: false);
      
      if (authProvider.user != null) {
        venueProvider.loadFavoriteVenues(authProvider.user!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        actions: [
          IconButton(
            onPressed: _loadFavorites,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Consumer3<ConnectivityProvider, AuthProvider, VenueProvider>(
        builder: (context, connectivityProvider, authProvider, venueProvider, child) {
          // Check connectivity
          if (!connectivityProvider.isConnected) {
            return NoInternetWidget(
              onRetry: _loadFavorites,
            );
          }

          // Check authentication
          if (authProvider.user == null) {
            return EmptyStateWidget(
              message: 'Please sign in to view your favorites',
              icon: Icons.favorite_border,
              action: ElevatedButton(
                onPressed: () {
                  // Navigate to login screen
                  Navigator.of(context).pushNamed('/login');
                },
                child: const Text('Sign In'),
              ),
            );
          }

          // Loading state
          if (venueProvider.isLoadingFavorites && venueProvider.favoriteVenues.isEmpty) {
            return const VenueListShimmer();
          }

          // Error state
          if (venueProvider.error != null && venueProvider.favoriteVenues.isEmpty) {
            return CustomErrorWidget(
              message: venueProvider.error!,
              onRetry: _loadFavorites,
            );
          }

          // Empty state
          if (venueProvider.favoriteVenues.isEmpty) {
            return EmptyStateWidget(
              message: 'No favorite venues yet.\nStart exploring and save venues you love!',
              icon: Icons.favorite_border,
              action: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to venues screen
                  Navigator.of(context).pushNamed('/venues');
                },
                icon: const Icon(Icons.explore),
                label: const Text('Explore Venues'),
              ),
            );
          }

          // Favorites list
          return RefreshIndicator(
            onRefresh: () async {
              await venueProvider.refreshFavorites(authProvider.user!.uid);
            },
            child: ListView.builder(
              itemCount: venueProvider.favoriteVenues.length,
              itemBuilder: (context, index) {
                final venue = venueProvider.favoriteVenues[index];
                return VenueCard(
                  venue: venue,
                  isFavorite: true,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => VenueDetailScreen(venue: venue),
                      ),
                    );
                  },
                  onFavoriteTap: () {
                    venueProvider.toggleFavorite(authProvider.user!.uid, venue.id);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
