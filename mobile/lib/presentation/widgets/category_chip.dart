import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CategoryChip extends StatelessWidget {
  final String name;
  final String icon;
  final String color;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.name,
    required this.icon,
    required this.color,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color chipColor;
    try {
      chipColor = Color(int.parse(color.replaceFirst('#', '0xFF')));
    } catch (_) {
      chipColor = AppColors.primary;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? chipColor.withValues(alpha: 0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _resolveCategoryIcon(icon),
              size: 14,
              color: isSelected ? chipColor : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? chipColor : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static IconData _resolveCategoryIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'food':
      case 'restaurant':
        return Icons.restaurant;
      case 'shopping':
        return Icons.shopping_bag;
      case 'transport':
      case 'directions_car':
        return Icons.directions_car;
      case 'bills':
      case 'receipt':
        return Icons.receipt_long;
      case 'entertainment':
      case 'movie':
        return Icons.movie;
      case 'salary':
      case 'work':
        return Icons.payments;
      case 'bonus':
        return Icons.card_giftcard;
      case 'investment':
        return Icons.show_chart;
      case 'health':
      case 'medical':
        return Icons.local_hospital;
      case 'education':
      case 'school':
        return Icons.school;
      default:
        return Icons.category;
    }
  }
}
