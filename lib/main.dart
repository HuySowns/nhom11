import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/auth_provider.dart';
import 'services/destination_provider.dart';
import 'services/admin_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/add_destination_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/bookings_screen.dart';
import 'screens/main_screen.dart';
import 'screens/admin_stats_screen.dart';
import 'screens/admin_management_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DestinationProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        title: 'Travel App',
        theme: ThemeData(
          useMaterial3: true,
          primaryColor: const Color(0xFF00897B),
          primarySwatch: Colors.teal,
          scaffoldBackgroundColor: const Color(0xFFFAFAFA),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF00897B),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 8,
            shadowColor: Colors.teal.withValues(alpha: 0.15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            clipBehavior: Clip.antiAlias,
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 15),
            prefixIconColor: Colors.teal,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00897B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              shadowColor: Colors.teal.withValues(alpha: 0.3),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          textTheme: const TextTheme(
            headlineLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A),
              letterSpacing: -0.5,
            ),
            headlineSmall: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
              letterSpacing: 0.2,
            ),
            titleMedium: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
            bodyMedium: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Color(0xFF424242),
              height: 1.5,
            ),
            bodySmall: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Color(0xFF757575),
            ),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: const Color(0xFF00897B),
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/add_destination': (context) => const AddDestinationScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/bookings': (context) => const BookingsScreen(),
          '/main': (context) => const MainScreen(),
          '/admin_stats': (context) => const AdminStatsScreen(),
          '/admin_management': (context) => const AdminManagementScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/booking') {
            final destination = settings.arguments as dynamic;
            return MaterialPageRoute(
              builder: (context) => BookingScreen(destination: destination),
            );
          }
          return null;
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final firebaseUser = authProvider.firebaseUser;

        if (firebaseUser == null) {
          return const LoginScreen();
        } else {
          return const MainScreen();
        }
      },
    );
  }
}
