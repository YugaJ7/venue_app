import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/venue_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/venue_card.dart';
import '../../widgets/venue_skeleton.dart';
import '../../widgets/error_widget.dart';
import 'venue_detail_screen.dart';

class VenueListScreen extends StatefulWidget {
  const VenueListScreen({super.key});

  @override
  State<VenueListScreen> createState() => _VenueListScreenState();
}

class _VenueListScreenState extends State<VenueListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadVenues();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadVenues() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final venueProvider = Provider.of<VenueProvider>(context, listen: false);
      venueProvider.loadVenues(refresh: true);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final venueProvider = Provider.of<VenueProvider>(context, listen: false);
      if (!venueProvider.isLoading && !venueProvider.isLoadingMore && venueProvider.hasMoreData) {
        venueProvider.loadVenues();
      }
    }
  }

  void _onSearchChanged(String query) {
    final venueProvider = Provider.of<VenueProvider>(context, listen: false);
    if (query.trim().isEmpty) {
      venueProvider.loadVenues(refresh: true);
    } else {
      venueProvider.searchVenues(query);
    }
  }

  void _onCategorySelected(String? category) {
    final venueProvider = Provider.of<VenueProvider>(context, listen: false);
    venueProvider.loadVenues(category: category, refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Venues'),
        actions: [
          IconButton(
            onPressed: () {
              _showCategoryFilter(context);
            },
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Consumer2<ConnectivityProvider, VenueProvider>(
        builder: (context, connectivityProvider, venueProvider, child) {
          // Check connectivity
          if (!connectivityProvider.isConnected) {
            return NoInternetWidget(
              onRetry: _loadVenues,
            );
          }

          return SafeArea(
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search venues...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                              icon: const Icon(Icons.clear),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
                // Content
                Expanded(
                  child: _buildContent(venueProvider),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(VenueProvider venueProvider) {
    if (venueProvider.isLoading && venueProvider.venues.isEmpty) {
      return const VenueListSkeleton();
    }

    if (venueProvider.error != null && venueProvider.venues.isEmpty) {
      return CustomErrorWidget(
        message: venueProvider.error!,
        onRetry: _loadVenues,
      );
    }

    if (venueProvider.venues.isEmpty) {
      return EmptyStateWidget(
        message: venueProvider.searchQuery != null
            ? 'No venues found for "${venueProvider.searchQuery}"'
            : 'No venues available',
        icon: Icons.search_off,
        action: venueProvider.searchQuery != null
            ? ElevatedButton(
                onPressed: () {
                  _searchController.clear();
                  _onSearchChanged('');
                },
                child: const Text('Clear Search'),
              )
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await venueProvider.refreshVenues();
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: venueProvider.venues.length + (venueProvider.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= venueProvider.venues.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final venue = venueProvider.venues[index];
          return VenueCard(
            venue: venue,
            isFavorite: venueProvider.isVenueFavorite(venue.id),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => VenueDetailScreen(venue: venue),
                ),
              );
            },
            onFavoriteTap: () {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              if (authProvider.user != null) {
                venueProvider.toggleFavorite(authProvider.user!.uid, venue.id);
              }
            },
          );
        },
      ),
    );
  }

  void _showCategoryFilter(BuildContext context) {
    final venueProvider = Provider.of<VenueProvider>(context, listen: false);
    final categories = venueProvider.categories;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter by Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('All Categories'),
              leading: const Icon(Icons.all_inclusive),
              onTap: () {
                _onCategorySelected(null);
                Navigator.of(context).pop();
              },
            ),
            ...categories.map((category) => ListTile(
              title: Text(category),
              leading: const Icon(Icons.category),
              onTap: () {
                _onCategorySelected(category);
                Navigator.of(context).pop();
              },
            )),
          ],
        ),
      ),
    );
  }
}
