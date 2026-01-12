import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/realtime_service.dart';
import '../models/booking.dart';
import '../models/destination.dart';
import 'booking_detail_screen.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  _BookingsScreenState createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> with WidgetsBindingObserver {
  final RealtimeService _realtimeService = RealtimeService();
  List<Booking> _bookings = [];
  List<Destination> _destinations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadBookings();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadBookings();
    }
  }

  Future<void> _loadBookings() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final bookings = await _realtimeService.getUserBookings(user.uid);
      final destinations = await _realtimeService.getDestinations();
      
      setState(() {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        elevation: 0,
        backgroundColor: const Color(0xFF00897B),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00897B)),
              ),
            )
          : _bookings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.book_online, size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'No bookings yet',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start exploring and book your first trip!',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadBookings,
                  color: const Color(0xFF00897B),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _bookings.length,
                    itemBuilder: (context, index) {
                      final booking = _bookings[index];
                      final destination = _getDestination(booking.destinationId);
                      if (destination == null) return const SizedBox();

                      return Card(
                        elevation: 6,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookingDetailScreen(
                                  booking: booking,
                                  destination: destination,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: destination.imageUrls.isNotEmpty
                                      ? Image.network(
                                          destination.imageUrls[0],
                                          width: 90,
                                          height: 90,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          width: 90,
                                          height: 90,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            gradient: LinearGradient(
                                              colors: [const Color(0xFF00897B).withValues(alpha: 0.5), const Color(0xFF004D40)],
                                            ),
                                          ),
                                          child: const Icon(Icons.image, size: 40, color: Colors.white),
                                        ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        destination.name,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1A1A1A),
                                        ),
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
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF00897B).withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.calendar_today, size: 13, color: Color(0xFF00897B)),
                                                const SizedBox(width: 4),
                                                Text(
                                                  booking.date.toLocal().toString().split(' ')[0],
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF00897B),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: Colors.amber.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.people, size: 13, color: Colors.amber),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${booking.numPeople}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.amber,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward, color: Color(0xFF00897B), size: 20),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}