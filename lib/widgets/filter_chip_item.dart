import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class FilterChipItem extends StatelessWidget {
  final String label;
  final bool selected;
  final IconData? icon;

  const FilterChipItem({
    super.key,
    required this.label,
    this.selected = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: selected ? AppColors.orange : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: selected ? AppColors.orange : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 18,
              color: selected ? Colors.white : AppColors.primaryText,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}
