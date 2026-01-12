import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/realtime_service.dart';
import '../models/favorite.dart';
import '../models/booking.dart';
import '../models/destination.dart';
import '../models/user.dart' as app_user;
import 'destination_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  final RealtimeService _realtimeService = RealtimeService();

  List<Favorite> _favorites = [];
  List<Booking> _bookings = [];
  List<Destination> _destinations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final favorites = await _realtimeService.getUserFavorites(user.uid);
      final bookings = await _realtimeService.getUserBookings(user.uid);
      final destinations = await _realtimeService.getDestinations();
      
      setState(() {
        _favorites = favorites;
        _bookings = bookings;
        _destinations = destinations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Destination? _getDestination(String id) {
    return _destinations.firstWhere((dest) => dest.id == id);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('User not logged in')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        elevation: 0,
        backgroundColor: const Color(0xFF00897B),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileHeader(user),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          TabBar(
                            tabs: const [
                              Tab(text: 'Bookings', icon: Icon(Icons.book_online)),
                              Tab(text: 'Favorites', icon: Icon(Icons.favorite)),
                            ],
                            labelColor: const Color(0xFF00897B),
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: const Color(0xFF00897B),
                            indicatorWeight: 3,
                          ),
                          SizedBox(
                            height: 400,
                            child: TabBarView(
                              children: [
                                _buildBookingsList(),
                                _buildFavoritesList(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader(app_user.AppUser user) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF00897B), const Color(0xFF004D40)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
              child: user.avatarUrl == null
                  ? const Icon(Icons.person, size: 60, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user.email,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                user.role.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await context.read<AuthProvider>().signOut();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF00897B),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesList() {
    if (_favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No favorites yet',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _favorites.length,
      itemBuilder: (context, index) {
        final favorite = _favorites[index];
        final destination = _getDestination(favorite.destinationId);
        if (destination == null) return const SizedBox();

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DestinationDetailScreen(destination: destination),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: destination.imageUrls.isNotEmpty
                        ? Image.network(destination.imageUrls[0], width: 70, height: 70, fit: BoxFit.cover)
                        : Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                colors: [const Color(0xFF00897B).withValues(alpha: 0.5), const Color(0xFF004D40)],
                              ),
                            ),
                            child: const Icon(Icons.image, color: Colors.white),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          destination.name,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: Color(0xFF00897B)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                destination.location,
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 14, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              destination.rating.toString(),
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.favorite, color: Colors.red, size: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookingsList() {
    if (_bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_online, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No bookings yet',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _bookings.length,
      itemBuilder: (context, index) {
        final booking = _bookings[index];
        final destination = _getDestination(booking.destinationId);
        if (destination == null) return const SizedBox();

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DestinationDetailScreen(destination: destination),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: destination.imageUrls.isNotEmpty
                        ? Image.network(destination.imageUrls[0], width: 70, height: 70, fit: BoxFit.cover)
                        : Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                colors: [const Color(0xFF00897B).withValues(alpha: 0.5), const Color(0xFF004D40)],
                              ),
                            ),
                            child: const Icon(Icons.image, color: Colors.white),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          destination.name,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Booking Date: ${booking.date.toLocal().toString().split(' ')[0]}',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00897B).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${booking.numPeople} people',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF00897B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward, color: Color(0xFF00897B), size: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}