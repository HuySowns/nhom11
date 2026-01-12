import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class LoadingWidget extends StatelessWidget {
  final String message;

  const LoadingWidget({
    Key? key,
    this.message = 'Loading...',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onActionPressed;
  final String? actionLabel;

  const EmptyStateWidget({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onActionPressed,
    this.actionLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (onActionPressed != null && actionLabel != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onActionPressed,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double elevation;
  final EdgeInsets padding;
  final BorderRadius borderRadius;

  const CustomCard({
    Key? key,
    required this.child,
    this.onTap,
    this.elevation = AppDimensions.cardElevation,
    this.padding = const EdgeInsets.all(AppDimensions.paddingMedium),
    this.borderRadius = const BorderRadius.all(
      Radius.circular(AppDimensions.radiusXLarge),
    ),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

class PriceTag extends StatelessWidget {
  final double price;
  final bool isHighlighted;

  const PriceTag({
    Key? key,
    required this.price,
    this.isHighlighted = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSmall,
        vertical: AppDimensions.paddingXSmall,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Text(
        '\$${price.toStringAsFixed(0)}',
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class RatingWidget extends StatelessWidget {
  final double rating;
  final double iconSize;

  const RatingWidget({
    Key? key,
    required this.rating,
    this.iconSize = AppDimensions.iconSmall,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star, size: iconSize, color: Colors.amber),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
