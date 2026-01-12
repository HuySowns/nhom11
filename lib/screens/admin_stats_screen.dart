import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/admin_provider.dart';

class AdminStatsScreen extends StatefulWidget {
  const AdminStatsScreen({super.key});

  @override
  _AdminStatsScreenState createState() => _AdminStatsScreenState();
}

class _AdminStatsScreenState extends State<AdminStatsScreen> {
  bool _expandTopDestinations = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AdminProvider>().loadAllStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        elevation: 0,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/admin_management'),
                icon: const Icon(Icons.manage_accounts, size: 22),
                label: const Text(
                  'Manage',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  elevation: 4,
                  shadowColor: Colors.teal.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (adminProvider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading statistics...',
                    style: TextStyle(color: Colors.teal.shade600, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.0,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStatCard(
                      title: 'Total Destinations',
                      value: adminProvider.totalDestinations.toString(),
                      icon: Icons.location_on,
                      color: Colors.blue,
                    ),
                    _buildStatCard(
                      title: 'Total Bookings',
                      value: adminProvider.totalBookings.toString(),
                      icon: Icons.book_online,
                      color: Colors.green,
                    ),
                    _buildStatCard(
                      title: 'Total Users',
                      value: adminProvider.totalUsers.toString(),
                      icon: Icons.people,
                      color: Colors.purple,
                    ),
                    _buildStatCard(
                      title: 'Avg Rating',
                      value: adminProvider.averageRating.toStringAsFixed(2),
                      icon: Icons.star,
                      color: Colors.amber,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Revenue Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.teal.shade500, Colors.teal.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.attach_money, color: Colors.white, size: 32),
                          const SizedBox(width: 12),
                          Text(
                            'Total Revenue',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _formatCurrency(adminProvider.totalRevenue),
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Top Destinations
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Top Destinations by Bookings',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _expandTopDestinations = !_expandTopDestinations;
                        });
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      ),
                      child: Text(
                        _expandTopDestinations ? 'Show Less ▲' : 'See More ▼',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildTopDestinationsList(adminProvider, _expandTopDestinations),
                const SizedBox(height: 18),

                // Detailed Stats Section
                Text(
                  'Booking Statistics',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                _buildBookingStats(context, adminProvider),
                const SizedBox(height: 60),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      shadowColor: color.withValues(alpha: 0.2),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.02)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: color.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopDestinationsList(AdminProvider adminProvider, bool expand) {
    final allTopDestinations = adminProvider.getTopDestinations(100);
    final topDestinations = expand ? allTopDestinations : allTopDestinations.take(5).toList();

    if (topDestinations.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No bookings yet',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: topDestinations.length,
      itemBuilder: (context, index) {
        final entry = topDestinations[index];
        final percentage = (entry.value / adminProvider.totalBookings * 100).toStringAsFixed(1);

        return Card(
          margin: const EdgeInsets.only(bottom: 6),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${entry.value} bookings',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.teal,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: entry.value / adminProvider.totalBookings,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.teal.shade600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$percentage% of total bookings',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookingStats(BuildContext context, AdminProvider adminProvider) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final currentMonth = DateTime.now().month;
    final maxBookings = List.generate(12, (i) => adminProvider.getBookingsByMonth(i + 1))
        .fold<int>(0, (max, val) => val > max ? val : max)
        .toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(12, (index) {
                  final bookings = adminProvider.getBookingsByMonth(index + 1);
                  final isCurrentMonth = index + 1 == currentMonth;
                  final height = maxBookings > 0 ? (bookings / maxBookings) * 160 : 0.0;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Tooltip(
                        message: '${months[index]}: $bookings bookings',
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: height,
                              decoration: BoxDecoration(
                                color: isCurrentMonth ? Colors.teal : Colors.teal.shade300,
                                borderRadius:
                                    const BorderRadius.vertical(top: Radius.circular(4)),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              months[index],
                              style: const TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Monthly Bookings Trend',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    // Format: $1,234.56
    final parts = amount.toStringAsFixed(2).split('.');
    final integerPart = parts[0];
    final decimalPart = parts[1];
    
    // Add comma separators for thousands
    String withCommas = '';
    final reversed = integerPart.split('').reversed.toList();
    for (int i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) {
        withCommas = ',' + withCommas;
      }
      withCommas = reversed[i] + withCommas;
    }
    
    return '\$$withCommas.$decimalPart';
  }
}
