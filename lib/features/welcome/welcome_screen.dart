import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../../data/local/local_storage_service.dart';
import '../home/home_screen.dart';
import '../participant/participant_form_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _enter(BuildContext context) {
    if (LocalStorageService.instance.hasParticipant()) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Realize o primeiro acesso para cadastrar o participante.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 136,
                height: 136,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'Icon/plante_seguro_pin.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Plante Seguro',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Diario eletronico de exposicao',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 54),
              AppButton(
                label: 'Entrar',
                icon: Icons.login,
                onPressed: () => _enter(context),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Primeiro acesso',
                icon: Icons.person,
                variant: AppButtonVariant.secondary,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ParticipantFormScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 22),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_off_outlined,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      'Funciona offline. Os dados ficam salvos no celular.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
