import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/firestore_service.dart';
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

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();

  List<Favorite> _favorites = [];
  List<Booking> _bookings = [];
  List<Destination> _destinations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    try {
      _favorites = await _firestoreService.getUserFavorites(user.uid);
      _bookings = await _firestoreService.getUserBookings(user.uid);
      _destinations = await _firestoreService.getDestinations();
    } catch (e) {
      print('Error loading profile data: $e');
    } finally {
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
        title: const Text('Profile'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Info'),
            Tab(text: 'Favorites & Bookings'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildInfoTab(user),
                _buildFavoritesBookingsTab(),
              ],
            ),
    );
  }

  Widget _buildInfoTab(app_user.AppUser user) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
            child: user.avatarUrl == null ? const Icon(Icons.person, size: 50) : null,
          ),
          const SizedBox(height: 16),
          Text('Name: ${user.name}', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text('Email: ${user.email}', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text('Role: ${user.role}', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesBookingsTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Favorites'),
              Tab(text: 'Bookings'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildFavoritesList(),
                _buildBookingsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList() {
    if (_favorites.isEmpty) {
      return const Center(child: Text('No favorites yet'));
    }

    return ListView.builder(
      itemCount: _favorites.length,
      itemBuilder: (context, index) {
        final favorite = _favorites[index];
        final destination = _getDestination(favorite.destinationId);
        if (destination == null) return const SizedBox();

        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: destination.imageUrls.isNotEmpty
                ? Image.network(destination.imageUrls[0], width: 50, height: 50, fit: BoxFit.cover)
                : const Icon(Icons.image),
            title: Text(destination.name),
            subtitle: Text(destination.location),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DestinationDetailScreen(destination: destination),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBookingsList() {
    if (_bookings.isEmpty) {
      return const Center(child: Text('No bookings yet'));
    }

    return ListView.builder(
      itemCount: _bookings.length,
      itemBuilder: (context, index) {
        final booking = _bookings[index];
        final destination = _getDestination(booking.destinationId);
        if (destination == null) return const SizedBox();

        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: destination.imageUrls.isNotEmpty
                ? Image.network(destination.imageUrls[0], width: 50, height: 50, fit: BoxFit.cover)
                : const Icon(Icons.image),
            title: Text(destination.name),
            subtitle: Text('Date: ${booking.date.toLocal().toString().split(' ')[0]}, People: ${booking.numPeople}'),
            onTap: () {
              // Maybe show booking details
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}