import 'package:flutter/material.dart';
import '../services/realtime_service.dart';
import '../models/user.dart' as app_user;
import '../models/destination.dart';
import '../models/booking.dart';
import '../constants/app_constants.dart';
import '../utils/app_utils.dart';

class AdminManagementScreen extends StatefulWidget {
  const AdminManagementScreen({super.key});

  @override
  _AdminManagementScreenState createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final RealtimeService _realtimeService = RealtimeService();

  List<app_user.AppUser> _users = [];
  List<Destination> _destinations = [];
  List<Booking> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final users = await _realtimeService.getUsers();
      final destinations = await _realtimeService.getDestinations();
      final bookings = await _realtimeService.getBookings();

      setState(() {
        _users = users;
        _destinations = destinations;
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      AppUtils.showErrorSnackBar(context, 'Error loading data: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Management'),
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Users', icon: Icon(Icons.people)),
            Tab(text: 'Destinations', icon: Icon(Icons.location_on)),
            Tab(text: 'Bookings', icon: Icon(Icons.book_online)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildUsersTab(),
                _buildDestinationsTab(),
                _buildBookingsTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDestinationDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildUsersTab() {
    return ListView.builder(
      itemCount: _users.length,
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      itemBuilder: (context, index) {
        final user = _users[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(user.name[0]),
            ),
            title: Text(user.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.email),
                Text('Role: ${user.role}'),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  child: const Text('Delete'),
                  onTap: () => _deleteUser(user.uid),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDestinationsTab() {
    return ListView.builder(
      itemCount: _destinations.length,
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      itemBuilder: (context, index) {
        final destination = _destinations[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
          child: ListTile(
            leading: destination.imageUrls.isNotEmpty
                ? Image.network(destination.imageUrls[0],
                    width: 50, height: 50, fit: BoxFit.cover)
                : const Icon(Icons.image),
            title: Text(destination.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(destination.location),
                Text('\$${destination.price.toStringAsFixed(0)}'),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  child: const Text('Edit'),
                  onTap: () => _showEditDestinationDialog(destination),
                ),
                PopupMenuItem(
                  child: const Text('Delete'),
                  onTap: () => _deleteDestination(destination.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookingsTab() {
    return ListView.builder(
      itemCount: _bookings.length,
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      itemBuilder: (context, index) {
        final booking = _bookings[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
          child: ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text('Booking #${booking.id.substring(0, 8)}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date: ${AppUtils.formatDate(booking.date)}'),
                Text('People: ${booking.numPeople}'),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  child: const Text('Delete'),
                  onTap: () => _deleteBooking(booking.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  void _showAddDestinationDialog() {
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final ratingController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Destination'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: ratingController,
                decoration: const InputDecoration(labelText: 'Rating'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final destination = Destination(
                  id: '',
                  name: nameController.text,
                  location: locationController.text,
                  description: descriptionController.text,
                  price: double.parse(priceController.text),
                  rating: double.parse(ratingController.text),
                  imageUrls: [],
                );
                await _realtimeService.addDestination(destination);
                await _loadData();
                AppUtils.showSuccessSnackBar(
                    context, 'Destination added successfully!');
              } catch (e) {
                AppUtils.showErrorSnackBar(context, 'Error adding destination: $e');
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditDestinationDialog(Destination destination) {
    final nameController = TextEditingController(text: destination.name);
    final locationController =
        TextEditingController(text: destination.location);
    final descriptionController =
        TextEditingController(text: destination.description);
    final priceController =
        TextEditingController(text: destination.price.toString());
    final ratingController =
        TextEditingController(text: destination.rating.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Destination'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: ratingController,
                decoration: const InputDecoration(labelText: 'Rating'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _realtimeService.updateDestination(destination.id, {
                  'name': nameController.text,
                  'location': locationController.text,
                  'description': descriptionController.text,
                  'price': double.parse(priceController.text),
                  'rating': double.parse(ratingController.text),
                });
                await _loadData();
                AppUtils.showSuccessSnackBar(
                    context, 'Destination updated successfully!');
              } catch (e) {
                AppUtils.showErrorSnackBar(context, 'Error updating destination: $e');
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(String uid) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _realtimeService.deleteUser(uid);
                await _loadData();
                AppUtils.showSuccessSnackBar(context, 'User deleted successfully!');
              } catch (e) {
                AppUtils.showErrorSnackBar(context, 'Error deleting user: $e');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDestination(String id) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this destination?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _realtimeService.deleteDestination(id);
                await _loadData();
                AppUtils.showSuccessSnackBar(
                    context, 'Destination deleted successfully!');
              } catch (e) {
                AppUtils.showErrorSnackBar(context, 'Error deleting destination: $e');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBooking(String id) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _realtimeService.deleteBooking(id);
                await _loadData();
                AppUtils.showSuccessSnackBar(context, 'Booking deleted successfully!');
              } catch (e) {
                AppUtils.showErrorSnackBar(context, 'Error deleting booking: $e');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
