import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class OptionButton extends StatelessWidget {
  const OptionButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 42,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            backgroundColor: selected ? AppColors.primaryLight : Colors.white,
            foregroundColor: selected ? AppColors.primary : AppColors.textPrimary,
            side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
          child: FittedBox(child: Text(label)),
        ),
      ),
    );
  }
}
