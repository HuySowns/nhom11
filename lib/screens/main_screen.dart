import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import 'home_screen.dart';
import 'bookings_screen.dart';
import 'profile_screen.dart';
import 'admin_stats_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Build screens list based on user role
    final authProvider = context.read<AuthProvider>();
    final isAdmin = authProvider.user?.role == 'admin';
    
    _screens = [
      const HomeScreen(),
      const BookingsScreen(),
      const ProfileScreen(),
      if (isAdmin) const AdminStatsScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isAdmin = authProvider.user?.role == 'admin';

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            activeIcon: Icon(Icons.explore_outlined),
            label: 'Explore',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            activeIcon: Icon(Icons.book_online_outlined),
            label: 'Bookings',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            activeIcon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
          if (isAdmin)
            const BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              activeIcon: Icon(Icons.bar_chart_outlined),
              label: 'Statistics',
            ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}