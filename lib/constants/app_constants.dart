import 'package:flutter/material.dart';

// Colors
class AppColors {
  static const Color primary = Color(0xFF00897B);
  static const Color primaryDark = Color(0xFF004D40);
  static const Color primaryLight = Color(0xFF4DB6AC);
  static const Color surface = Color(0xFFFAFAFA);
  static const Color text = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF999999);
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF43A047);
  static const Color warning = Color(0xFFFDD835);
  static const Color accent = Color(0xFFFFB300);
}

// Dimensions
class AppDimensions {
  // Border radius
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 20.0;

  // Padding and spacing
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 12.0;
  static const double paddingLarge = 16.0;
  static const double paddingXLarge = 24.0;

  // Icon sizes
  static const double iconSmall = 12.0;
  static const double iconMedium = 16.0;
  static const double iconLarge = 24.0;
  static const double iconXLarge = 40.0;

  // Card dimensions
  static const double cardImageHeight = 130.0;
  static const double cardElevation = 6.0;
  static const double cardShadowBlur = 6.0;

  // Grid
  static const int gridColumnCount = 2;
  static const double gridSpacing = 12.0;
  static const double gridChildAspectRatio = 0.70;

  // Featured card
  static const double featuredCardWidth = 200.0;
  static const double featuredCardHeight = 280.0;
}

// Typography
class AppTypography {
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.w800,
    color: Colors.white,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    color: AppColors.text,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: AppColors.text,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );
}

// Durations
class AppDurations {
  static const Duration short = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration long = Duration(milliseconds: 500);
}

// Strings
class AppStrings {
  static const String appName = 'Vietnam Tours';
  static const String explore = 'Explore';
  static const String bookings = 'Bookings';
  static const String profile = 'Profile';
  static const String statistics = 'Statistics';
  static const String loading = 'Loading destinations...';
  static const String noDestinations = 'No destinations found';
  static const String noBookings = 'No bookings yet';
  static const String noFavorites = 'No favorites yet';
  static const String trendingNow = 'Trending Now';
  static const String exploreAll = 'Explore All';
  static const String categories = 'Categories';
  static const String hot = '🔥 Hot';
  static const String seeAll = 'See all';
}
