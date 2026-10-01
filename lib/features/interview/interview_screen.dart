import 'package:flutter/material.dart';

import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/option_button.dart';
import '../../core/widgets/section_title.dart';
import '../../data/local/local_storage_service.dart';
import '../../data/models/interview_model.dart';

class InterviewScreen extends StatefulWidget {
  const InterviewScreen({super.key});

  @override
  State<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends State<InterviewScreen> {
  final _observationsController = TextEditingController();
  String? _contactLast30Days;
  String? _frequency;
  String? _familyExposure;

  @override
  void dispose() {
    _observationsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final participant = LocalStorageService.instance.getParticipant();
    if (participant == null) return;
    final now = DateTime.now();
    await LocalStorageService.instance.saveInterview(
      InterviewModel(
        id: 'interview_${now.microsecondsSinceEpoch}',
        participantId: participant.id,
        contactLast30Days: _contactLast30Days ?? '',
        frequency: _frequency ?? '',
        familyExposure: _familyExposure ?? '',
        observations: _observationsController.text.trim().isEmpty ? null : _observationsController.text.trim(),
        createdAt: now,
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Entrevista salva localmente.')),
    );
    setState(() {
      _contactLast30Days = null;
      _frequency = null;
      _familyExposure = null;
      _observationsController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entrevistas')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle(title: 'Entrevista periodica', icon: Icons.fact_check_outlined),
                  const SizedBox(height: 16),
                  const Text('Nos ultimos 30 dias, voce teve contato com agrotoxicos?', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      OptionButton(label: 'Sim', selected: _contactLast30Days == 'Sim', onTap: () => setState(() => _contactLast30Days = 'Sim')),
                      const SizedBox(width: 8),
                      OptionButton(label: 'Nao', selected: _contactLast30Days == 'Nao', onTap: () => setState(() => _contactLast30Days = 'Nao')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Com que frequencia voce utiliza ou acompanha aplicacao de agrotoxicos?', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['Raramente', 'Semanalmente', 'Varias vezes por semana', 'Diariamente'].map((option) {
                      final selected = _frequency == option;
                      return ChoiceChip(
                        label: Text(option),
                        selected: selected,
                        onSelected: (_) => setState(() => _frequency = option),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text('Algum familiar teve contato proximo com agrotoxicos?', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      OptionButton(label: 'Sim', selected: _familyExposure == 'Sim', onTap: () => setState(() => _familyExposure = 'Sim')),
                      const SizedBox(width: 8),
                      OptionButton(label: 'Nao', selected: _familyExposure == 'Nao', onTap: () => setState(() => _familyExposure = 'Nao')),
                      const SizedBox(width: 8),
                      OptionButton(label: 'Nao sei', selected: _familyExposure == 'Nao sei', onTap: () => setState(() => _familyExposure = 'Nao sei')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Observacoes gerais',
                    placeholder: 'Digite informacoes adicionais (opcional)',
                    controller: _observationsController,
                    maxLines: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppButton(label: 'Salvar entrevista', icon: Icons.save_outlined, onPressed: _save),
          ],
        ),
      ),
    );
  }
}
