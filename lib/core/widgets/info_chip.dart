import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class InfoChip extends StatelessWidget {
  const InfoChip({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.alert = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool alert;

  @override
  Widget build(BuildContext context) {
    final color = alert ? AppColors.warning : AppColors.primary;
    return Expanded(
      child: Container(
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: alert ? const Color(0xFFFFFBEB) : AppColors.primaryLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
