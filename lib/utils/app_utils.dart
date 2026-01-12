import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AppUtils {
  /// Format currency to display price
  static String formatPrice(double price) {
    return '\$${price.toStringAsFixed(0)}';
  }

  /// Format date to readable string
  static String formatDate(DateTime date) {
    return date.toLocal().toString().split(' ')[0];
  }

  /// Create gradient background
  static LinearGradient createGradient({
    Color startColor = AppColors.primary,
    Color endColor = AppColors.primaryDark,
  }) {
    return LinearGradient(
      colors: [startColor, endColor],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  /// Create box shadow
  static BoxShadow createShadow({
    Color color = Colors.black,
    double alpha = 0.15,
    double blurRadius = 4.0,
  }) {
    return BoxShadow(
      color: color.withValues(alpha: alpha),
      blurRadius: blurRadius,
    );
  }

  /// Show error snackbar
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  /// Show success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }

  /// Navigate to screen
  static void navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  /// Navigate and replace
  static void navigateToReplacement(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}
