import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/local/local_storage_service.dart';
import '../../data/models/exposure_record_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late List<ExposureRecordModel> _records;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _records = LocalStorageService.instance.getExposureRecords();
  }

  Future<void> _syncPending() async {
    await LocalStorageService.instance.markPendingRecordsAsSynced();
    setState(_load);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registros pendentes sincronizados de forma simulada.')),
    );
  }

  void _showDetails(ExposureRecordModel record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        final gps = record.latitude == null || record.longitude == null
            ? 'Nao registrado'
            : '${record.latitude!.toStringAsFixed(5)}, ${record.longitude!.toStringAsFixed(5)}';
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Detalhes do registro', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                      ),
                      StatusBadge(status: record.status),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _DetailRow(label: 'Data', value: record.date),
                  _DetailRow(label: 'Hora', value: record.time),
                  _DetailRow(label: 'Apresentou sintomas', value: _yesNo(record.hadSymptoms)),
                  _DetailRow(label: 'Como se sente hoje', value: _text(record.howFeelToday)),
                  _DetailRow(label: 'Aplicado na propriedade', value: _text(record.appliedOnProperty)),
                  _DetailRow(label: 'Pessoas na casa', value: record.peopleAtHome?.toString() ?? 'Nao informado'),
                  _DetailRow(label: 'Cultura', value: _text(record.crop)),
                  _DetailRow(label: 'Produto', value: _text(record.productName)),
                  _DetailRow(label: 'Tempo de exposicao', value: _text(record.exposureTime)),
                  _DetailRow(label: 'EPI', value: _text(record.usedPpe)),
                  _DetailRow(label: 'GPS', value: gps),
                  if (record.photoPath != null) ...[
                    const SizedBox(height: 10),
                    const Text('Foto', style: TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(record.photoPath!),
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Text('Imagem nao encontrada no dispositivo.'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pending = _records.where((record) => record.status == 'Pendente').length;
    return Scaffold(
      appBar: AppBar(title: const Text('Historico')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Registros mais recentes', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                  Text('Total: ${_records.length}', style: const TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),
            Expanded(
              child: _records.isEmpty
                  ? const Center(child: Text('Nenhum registro salvo localmente.'))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemBuilder: (context, index) {
                        final record = _records[index];
                        return AppCard(
                          onTap: () => _showDetails(record),
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 72,
                                child: Text(
                                  '${record.date}\n${record.time}',
                                  style: const TextStyle(fontWeight: FontWeight.w800),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_text(record.productName), style: const TextStyle(fontWeight: FontWeight.w900)),
                                    Text('${_text(record.crop)} - ${_text(record.exposureTime)}', style: const TextStyle(color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                              StatusBadge(status: record.status),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemCount: _records.length,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: AppButton(
                label: pending > 0 ? 'Reenviar pendentes ($pending)' : 'Reenviar pendentes',
                icon: Icons.sync,
                onPressed: _syncPending,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _text(String? value) {
  if (value == null || value.trim().isEmpty) return 'Nao informado';
  return value;
}

String _yesNo(bool? value) {
  if (value == null) return 'Nao informado';
  return value ? 'Sim' : 'Nao';
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w800)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }
}
