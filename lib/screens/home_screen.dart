import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/destination_provider.dart';
import '../models/destination.dart';
import 'destination_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  List<Destination> _destinations = [];
  List<Destination> _filteredDestinations = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadDestinations();
    _searchController.addListener(_filterDestinations);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadDestinations();
    }
  }

  Future<void> _loadDestinations() async {
    try {
      await context.read<DestinationProvider>().loadDestinations();
      _destinations = context.read<DestinationProvider>().destinations;
      _filterDestinations();
    } catch (e) {
      print('Error loading destinations: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterDestinations() {
    final query = _searchController.text.toLowerCase().trim();
    
    List<Destination> filtered = _destinations.where((dest) {
      // Search by name, location, or description
      final matchesSearch = dest.name.toLowerCase().contains(query) ||
          dest.location.toLowerCase().contains(query) ||
          dest.description.toLowerCase().contains(query);
      return matchesSearch;
    }).toList();

    // Apply category filter
    if (_selectedCategory != 'All') {
      if (_selectedCategory == 'High Rated') {
        filtered = filtered.where((dest) => dest.rating >= 4.0).toList();
        // Sort by rating (highest first)
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
      } else if (_selectedCategory == 'Popular') {
        // Filter destinations with engagement (favorites or bookings)
        filtered = filtered.where((dest) => dest.favoritesCount > 0 || dest.bookingsCount > 0).toList();
        // Sort by total engagement (favorites + bookings)
        filtered.sort((a, b) {
          int aTotalEngagement = a.favoritesCount + a.bookingsCount;
          int bTotalEngagement = b.favoritesCount + b.bookingsCount;
          
          if (aTotalEngagement != bTotalEngagement) {
            return bTotalEngagement.compareTo(aTotalEngagement);
          }
          
          // If engagement is same, sort by rating
          return b.rating.compareTo(a.rating);
        });
      }
    } else {
      // "All" category: sort by rating by default
      filtered.sort((a, b) => b.rating.compareTo(a.rating));
    }

    // Sort by relevance when searching (overrides category sorting)
    if (query.isNotEmpty) {
      filtered.sort((a, b) {
        // Prioritize name matches
        final aNameMatch = a.name.toLowerCase().startsWith(query) ? 0 : 1;
        final bNameMatch = b.name.toLowerCase().startsWith(query) ? 0 : 1;
        if (aNameMatch != bNameMatch) return aNameMatch.compareTo(bNameMatch);
        
        // Then by rating
        return b.rating.compareTo(a.rating);
      });
    }

    setState(() => _filteredDestinations = filtered);
  }

  void _onCategorySelected(String category) {
    setState(() => _selectedCategory = category);
    _filterDestinations();
  }

  List<Destination> _getTrendingDestinations() {
    // Sort destinations by favorites count and bookings count
    List<Destination> sorted = List.from(_destinations);
    sorted.sort((a, b) {
      // Primary sort: by total engagement (favorites + bookings)
      int aTotalEngagement = a.favoritesCount + a.bookingsCount;
      int bTotalEngagement = b.favoritesCount + b.bookingsCount;
      
      if (aTotalEngagement != bTotalEngagement) {
        return bTotalEngagement.compareTo(aTotalEngagement);
      }
      
      // Secondary sort: by favorites count
      if (a.favoritesCount != b.favoritesCount) {
        return b.favoritesCount.compareTo(a.favoritesCount);
      }
      
      // Tertiary sort: by bookings count
      if (a.bookingsCount != b.bookingsCount) {
        return b.bookingsCount.compareTo(a.bookingsCount);
      }
      
      // Final sort: by rating
      return b.rating.compareTo(a.rating);
    });
    
    // Return top 5 or less if fewer destinations available
    return sorted.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF00897B)),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading destinations...',
                    style: TextStyle(
                      color: const Color(0xFF00897B),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                // Sliver App Bar with Parallax
                SliverAppBar(
                  expandedHeight: 280,
                  floating: false,
                  pinned: true,
                  backgroundColor: const Color(0xFF00897B),
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text(
                      'Explore Destinations',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        letterSpacing: -0.3,
                        shadows: [
                          Shadow(
                            blurRadius: 4.0,
                            color: Colors.black54,
                            offset: Offset(0, 1),
                          ),
                          Shadow(
                            blurRadius: 8.0,
                            color: Colors.black45,
                            offset: Offset(1, 2),
                          ),
                        ],
                      ),
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
                          fit: BoxFit.cover,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withValues(alpha: 0.2),
                                Colors.black.withValues(alpha: 0.65),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.person_outline, color: Colors.white, size: 28),
                      onPressed: () {
                        Navigator.pushNamed(context, '/profile');
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white, size: 28),
                      onPressed: () async {
                        await context.read<AuthProvider>().signOut();
                      },
                    ),
                  ],
                ),
                // Search Bar with shadow
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00897B).withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Where do you want to explore?',
                          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                          prefixIcon: const Icon(Icons.location_on, color: Color(0xFF00897B), size: 24),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close_rounded, color: Color(0xFF00897B)),
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                )
                              : const Icon(Icons.search, color: Color(0xFF00897B), size: 24),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        ),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ),
                ),
                // Categories
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Categories',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: const Color(0xFF1A1A1A),
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              'See all',
                              style: TextStyle(
                                color: const Color(0xFF00897B),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 58,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          children: [
                            _buildCategoryChip('All'),
                            const SizedBox(width: 10),
                            _buildCategoryChip('Popular'),
                            const SizedBox(width: 10),
                            _buildCategoryChip('High Rated'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Featured Destinations
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Trending Now',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: const Color(0xFF1A1A1A),
                                fontSize: 20,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00897B).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '🔥 Hot',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF00897B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 280,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          itemCount: _getTrendingDestinations().length,
                          itemBuilder: (context, index) {
                            final destination = _getTrendingDestinations()[index];
                            return _buildFeaturedCard(destination);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // All Destinations
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                    child: Text(
                      'Explore All',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  sliver: _filteredDestinations.isEmpty
                      ? SliverToBoxAdapter(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No destinations found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.70,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final destination = _filteredDestinations[index];
                              return _buildDestinationCard(destination);
                            },
                            childCount: _filteredDestinations.length,
                          ),
                        ),
                ),
                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
              ],
            ),
      floatingActionButton: user?.role == 'admin'
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/add_destination');
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildFeaturedCard(Destination destination) {
    return Container(
      width: 240,
      height: 300,
      margin: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DestinationDetailScreen(destination: destination),
            ),
          );
        },
        child: Card(
          elevation: 4,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image with gradient overlay
                    Stack(
                      children: [
                        Container(
                          height: 160,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: destination.imageUrls.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(destination.imageUrls[0]),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            color: Colors.grey.shade300,
                          ),
                          child: destination.imageUrls.isEmpty
                              ? Center(
                                  child: Icon(Icons.landscape, size: 50, color: Colors.grey.shade600),
                                )
                              : null,
                        ),
                        // Gradient overlay for better text readability
                        Container(
                          height: 160,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.3)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  destination.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: Color(0xFF1A1A1A),
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.location_on, size: 12, color: Colors.teal.shade600),
                                    const SizedBox(width: 2),
                                    Expanded(
                                      child: Text(
                                        destination.location,
                                        style: TextStyle(color: Colors.grey.shade700, fontSize: 11),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // Rating and price row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 14),
                                    const SizedBox(width: 3),
                                    Text(
                                      destination.rating.toString(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '\$${destination.price.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.teal.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Top badges
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.favorite, size: 13, color: Colors.red),
                        const SizedBox(width: 4),
                        Text(
                          '${destination.favoritesCount}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDestinationCard(Destination destination) {
    return Card(
      elevation: 10,
      shadowColor: const Color(0xFF00897B).withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DestinationDetailScreen(destination: destination),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: 'destination-${destination.id}',
              child: Stack(
                children: [
                  Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      color: Colors.grey.shade200,
                      image: destination.imageUrls.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(destination.imageUrls[0]),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: destination.imageUrls.isEmpty
                        ? Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                              gradient: LinearGradient(
                                colors: [const Color(0xFF00897B), const Color(0xFF004D40)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Center(
                              child: Icon(Icons.landscape, size: 60, color: Colors.white),
                            ),
                          )
                        : null,
                  ),
                  // Star badge with better styling
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 13, color: Colors.amber),
                          const SizedBox(width: 3),
                          Text(
                            destination.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    destination.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: -0.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 13, color: Color(0xFF00897B)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          destination.location,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00897B),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '\$${destination.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00897B).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF00897B), size: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    return FilterChip(
      label: Text(
        category,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF00897B),
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          fontSize: 15,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) _onCategorySelected(category);
      },
      selectedColor: const Color(0xFF00897B),
      backgroundColor: Colors.white,
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      side: BorderSide(
        color: isSelected ? Colors.transparent : const Color(0xFF00897B).withValues(alpha: 0.3),
        width: 1.5,
      ),
      elevation: isSelected ? 6 : 2,
      shadowColor: const Color(0xFF00897B).withValues(alpha: 0.3),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}