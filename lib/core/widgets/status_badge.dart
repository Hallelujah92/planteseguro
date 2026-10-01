import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final color = switch (normalized) {
      'sincronizado' => AppColors.success,
      'erro' => AppColors.error,
      'local' => AppColors.primary,
      _ => AppColors.warning,
    };
    final icon = switch (normalized) {
      'sincronizado' => Icons.check_circle_outline,
      'erro' => Icons.error_outline,
      'local' => Icons.phone_android,
      _ => Icons.schedule,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
