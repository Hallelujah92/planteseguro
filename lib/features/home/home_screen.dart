import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/local/local_storage_service.dart';
import '../exposure/exposure_form_screen.dart';
import '../history/history_screen.dart';
import '../interview/interview_screen.dart';
import '../participant/participant_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _openMenu(String option) async {
    if (option == 'history') {
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const HistoryScreen()));
    } else if (option == 'interview') {
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const InterviewScreen()));
    } else if (option == 'switch') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Trocar usuario?'),
          content: const Text(
            'O cadastro atual sera encerrado. Os registros ja salvos serao mantidos.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Trocar'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      await LocalStorageService.instance.clearParticipant();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ParticipantFormScreen()),
        (_) => false,
      );
    }
  }

  Future<void> _sync() async {
    await LocalStorageService.instance.markPendingRecordsAsSynced();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sincronizacao simulada concluida.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final participant = LocalStorageService.instance.getParticipant();
    final name = participant?.nameOrCode ?? 'Participante';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        leading: PopupMenuButton<String>(
          tooltip: 'Menu',
          icon: const Icon(Icons.menu),
          onSelected: _openMenu,
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'interview',
              child: ListTile(
                leading: Icon(Icons.assignment_outlined),
                title: Text('Entrevista'),
              ),
            ),
            PopupMenuItem(
              value: 'history',
              child: ListTile(
                leading: Icon(Icons.history),
                title: Text('Historico'),
              ),
            ),
            PopupMenuItem(
              value: 'switch',
              child: ListTile(
                leading: Icon(Icons.switch_account),
                title: Text('Troca de usuario'),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppCard(
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 25,
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(
                      Icons.person,
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ola, Participante',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          name,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const StatusBadge(status: 'Local'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
              elevation: 2,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ExposureFormScreen()),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(18),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 27,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.add,
                          color: AppColors.primary,
                          size: 34,
                        ),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Clique aqui pra registrar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.white, size: 30),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            AppCard(
              onTap: _sync,
              child: const Row(
                children: [
                  Icon(Icons.cloud_upload, color: AppColors.primary, size: 30),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sincronizar agora',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                        Text(
                          'Sincronizacao pendente',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AppColors.textSecondary),
                ],
              ),
            ),
            const SizedBox(height: 14),
            AppCard(
              color: AppColors.primaryLight,
              child: const Row(
                children: [
                  Icon(Icons.notifications_none, color: AppColors.primary),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Registre a exposicao no momento em que ocorrer.',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
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
