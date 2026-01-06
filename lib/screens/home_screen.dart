import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/firestore_service.dart';
import '../models/destination.dart';
import 'destination_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Destination> _destinations = [];
  List<Destination> _filteredDestinations = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadDestinations();
    _searchController.addListener(_filterDestinations);
  }

  Future<void> _loadDestinations() async {
    try {
      _destinations = await _firestoreService.getDestinations();
      if (_destinations.isEmpty) {
        await _addSampleDestinations();
        _destinations = await _firestoreService.getDestinations();
      }
      _filterDestinations();
    } catch (e) {
      print('Error loading destinations: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addSampleDestinations() async {
    final samples = [
      Destination(
        id: '',
        name: 'Ha Long Bay',
        location: 'Vietnam',
        description: 'A UNESCO World Heritage site with stunning limestone karsts and emerald waters.',
        price: 150.0,
        rating: 4.8,
        imageUrls: [
          'https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
          'https://images.unsplash.com/photo-1584464491033-06628f3a6b7b?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80'
        ],
      ),
      Destination(
        id: '',
        name: 'Phu Quoc Island',
        location: 'Vietnam',
        description: 'Tropical paradise with beautiful beaches, luxury resorts, and vibrant nightlife.',
        price: 200.0,
        rating: 4.6,
        imageUrls: [
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
          'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80'
        ],
      ),
      Destination(
        id: '',
        name: 'Sapa Terraces',
        location: 'Vietnam',
        description: 'Breathtaking rice terraces, ethnic villages, and misty mountains.',
        price: 120.0,
        rating: 4.7,
        imageUrls: [
          'https://images.unsplash.com/photo-1549144511-f099e773c147?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80'
        ],
      ),
      Destination(
        id: '',
        name: 'Ho Chi Minh City',
        location: 'Vietnam',
        description: 'Vibrant city with French colonial architecture, bustling markets, and modern skyscrapers.',
        price: 100.0,
        rating: 4.5,
        imageUrls: [
          'https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
          'https://images.unsplash.com/photo-1584464491033-06628f3a6b7b?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80'
        ],
      ),
      Destination(
        id: '',
        name: 'Da Nang Marble Mountains',
        location: 'Vietnam',
        description: 'Sacred mountains with caves, temples, and panoramic views of the coastline.',
        price: 80.0,
        rating: 4.4,
        imageUrls: [
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
          'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80'
        ],
      ),
    ];

    for (final dest in samples) {
      await _firestoreService.addDestination(dest);
    }
  }

  void _filterDestinations() {
    final query = _searchController.text.toLowerCase();
    List<Destination> filtered = _destinations.where((dest) =>
        dest.name.toLowerCase().contains(query) ||
        dest.location.toLowerCase().contains(query)).toList();

    if (_selectedCategory != 'All') {
      if (_selectedCategory == 'High Rated') {
        filtered = filtered.where((dest) => dest.rating >= 4.0).toList();
      } else if (_selectedCategory == 'Popular') {
        filtered = filtered.where((dest) => dest.rating >= 3.5).toList();
      }
    }

    setState(() => _filteredDestinations = filtered);
  }

  void _onCategorySelected(String category) {
    setState(() => _selectedCategory = category);
    _filterDestinations();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Destinations'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading destinations...',
                    style: TextStyle(color: Colors.teal.shade600, fontSize: 16),
                  ),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                // Sliver App Bar with Parallax
                SliverAppBar(
                  expandedHeight: 250,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text(
                      'Explore Vietnam',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black26,
                            offset: Offset(2.0, 2.0),
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
                              colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
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
                      icon: const Icon(Icons.person, color: Colors.white),
                      onPressed: () {
                        Navigator.pushNamed(context, '/profile');
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: () async {
                        await context.read<AuthProvider>().signOut();
                      },
                    ),
                  ],
                ),
                // Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search destinations...',
                          prefixIcon: const Icon(Icons.search, color: Colors.teal),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.teal),
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
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
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Categories',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      SizedBox(
                        height: 60,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          children: [
                            _buildCategoryChip('All'),
                            const SizedBox(width: 8),
                            _buildCategoryChip('Popular'),
                            const SizedBox(width: 8),
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
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          'Featured Destinations',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      SizedBox(
                        height: 220,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: _destinations.length > 5 ? 5 : _destinations.length,
                          itemBuilder: (context, index) {
                            final destination = _destinations[index];
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
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      'All Destinations',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: _filteredDestinations.isEmpty
                      ? SliverToBoxAdapter(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No destinations found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
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
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
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
      width: 180,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 8,
        shadowColor: Colors.teal.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            gradient: LinearGradient(
                              colors: [Colors.teal.shade400, Colors.teal.shade700],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Center(child: Icon(Icons.image, size: 40, color: Colors.white)),
                        )
                      : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.teal),
                        const SizedBox(width: 4),
                        Text(
                          destination.location,
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(
                          destination.rating.toString(),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        Text(
                          '\$${destination.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDestinationCard(Destination destination) {
    return Card(
      elevation: 8,
      shadowColor: Colors.teal.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
          children: [
            Hero(
              tag: 'destination-${destination.id}',
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          gradient: LinearGradient(
                            colors: [Colors.teal.shade200, Colors.teal.shade400],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Center(child: Icon(Icons.image, size: 50, color: Colors.white)),
                      )
                    : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.teal),
                      const SizedBox(width: 4),
                      Text(
                        destination.location,
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(
                        destination.rating.toString(),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      Text(
                        '\$${destination.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
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
          color: isSelected ? Colors.white : Colors.teal,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) _onCategorySelected(category);
      },
      selectedColor: Colors.teal,
      backgroundColor: Colors.white,
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide(color: Colors.teal.withOpacity(0.5)),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}