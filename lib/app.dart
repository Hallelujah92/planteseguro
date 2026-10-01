import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/welcome/welcome_screen.dart';

class PlanteSeguroApp extends StatelessWidget {
  const PlanteSeguroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plante Seguro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const WelcomeScreen(),
    );
  }
}
