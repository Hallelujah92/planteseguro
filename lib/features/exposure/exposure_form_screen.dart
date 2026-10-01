import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/option_button.dart';
import '../../core/widgets/section_title.dart';
import '../../data/local/local_storage_service.dart';
import '../../data/models/exposure_record_model.dart';
import '../home/home_screen.dart';

class ExposureFormScreen extends StatefulWidget {
  const ExposureFormScreen({super.key});

  @override
  State<ExposureFormScreen> createState() => _ExposureFormScreenState();
}

class _ExposureFormScreenState extends State<ExposureFormScreen> {
  static const _symptomOptions = [
    'Dor de cabeca',
    'Tontura',
    'Nausea',
    'Ardor nos olhos',
    'Falta de ar',
    'Irritacao na pele',
    'Fraqueza',
    'Vomito',
  ];

  final _picker = ImagePicker();
  final _productController = TextEditingController();
  final _durationController = TextEditingController();
  final _peopleAtHomeController = TextEditingController();
  final _cropController = TextEditingController();
  final _date = DateFormat('dd/MM/yyyy').format(DateTime.now());
  final _time = DateFormat('HH:mm').format(DateTime.now());
  final _products = const [
    'Herbicida',
    'Inseticida',
    'Fungicida',
    'Produto nao informado',
    'Outro',
  ];
  final Set<String> _symptoms = {};

  String? _selectedProduct;
  String? _usedPpe;
  bool? _hadSymptoms;
  String? _appliedOnProperty;
  String? _photoPath;
  int? _exposureHour;
  int? _exposureMinute;
  double? _latitude;
  double? _longitude;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _tryGetLocation();
  }

  @override
  void dispose() {
    _productController.dispose();
    _durationController.dispose();
    _peopleAtHomeController.dispose();
    _cropController.dispose();
    super.dispose();
  }

  Future<void> _tryGetLocation() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      if (!mounted) {
        return;
      }
      _latitude = position.latitude;
      _longitude = position.longitude;
    } catch (_) {
      // O GPS e opcional e nunca deve impedir o registro.
    }
  }

  Future<void> _pickPhoto() async {
    XFile? file;
    try {
      file = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
    } catch (_) {
      try {
        file = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );
      } catch (_) {
        file = null;
      }
    }
    if (file != null && mounted) {
      setState(() => _photoPath = file!.path);
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    final participant = LocalStorageService.instance.getParticipant();
    if (participant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastre o participante antes de salvar registros.'),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    final now = DateTime.now();
    final peopleText = _peopleAtHomeController.text.trim();
    final record = ExposureRecordModel(
      id: 'exposure_${now.microsecondsSinceEpoch}',
      participantId: participant.id,
      date: _date,
      time: _time,
      latitude: _latitude,
      longitude: _longitude,
      crop: _cropController.text.trim(),
      productName: _selectedProduct == 'Outro'
          ? _productController.text.trim()
          : _selectedProduct ?? '',
      exposureTime: _durationController.text,
      usedPpe: _usedPpe ?? '',
      hadSymptoms: _hadSymptoms,
      appliedOnProperty: _appliedOnProperty,
      peopleAtHome: peopleText.isEmpty ? null : int.tryParse(peopleText),
      symptoms: _hadSymptoms == true ? _symptoms.toList() : const [],
      photoPath: _photoPath,
      status: 'Pendente',
      createdAt: now,
    );
    await LocalStorageService.instance.saveExposureRecord(record);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.eco, color: AppColors.primary, size: 42),
        title: const Text('Voce acaba de plantar uma informacao.'),
        content: const Text(
          'Obrigado por contribuir. Se os sintomas persistirem procure uma unidade de saude!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Concluir'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  Future<void> _openDurationPicker() async {
    var selectedHour = _exposureHour ?? 0;
    var selectedMinute = _exposureMinute ?? 0;
    final hourController = FixedExtentScrollController(
      initialItem: selectedHour,
    );
    final minuteController = FixedExtentScrollController(
      initialItem: selectedMinute,
    );
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF242424),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) => SafeArea(
        child: SizedBox(
          height: 330,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: Column(
              children: [
                const Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          'H',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'M',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: hourController,
                          itemExtent: 48,
                          magnification: 1.18,
                          useMagnifier: true,
                          selectionOverlay: const SizedBox.shrink(),
                          onSelectedItemChanged: (value) =>
                              selectedHour = value,
                          children: List.generate(
                            24,
                            (index) => Center(
                              child: Text(
                                index.toString().padLeft(2, '0'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: minuteController,
                          itemExtent: 48,
                          magnification: 1.18,
                          useMagnifier: true,
                          selectionOverlay: const SizedBox.shrink(),
                          onSelectedItemChanged: (value) =>
                              selectedMinute = value,
                          children: List.generate(
                            60,
                            (index) => Center(
                              child: Text(
                                index.toString().padLeft(2, '0'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          setState(() {
                            _exposureHour = selectedHour;
                            _exposureMinute = selectedMinute;
                            _durationController.text =
                                '${selectedHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')}';
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Concluido'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    hourController.dispose();
    minuteController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de exposicao')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle(
                    title: 'Dados da exposicao',
                    icon: Icons.eco,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Apresentou sintomas?',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      OptionButton(
                        label: 'Sim',
                        selected: _hadSymptoms == true,
                        onTap: () => setState(() => _hadSymptoms = true),
                      ),
                      const SizedBox(width: 8),
                      OptionButton(
                        label: 'Nao',
                        selected: _hadSymptoms == false,
                        onTap: () => setState(() {
                          _hadSymptoms = false;
                          _symptoms.clear();
                        }),
                      ),
                    ],
                  ),
                  if (_hadSymptoms == true) ...[
                    const SizedBox(height: 18),
                    const Text(
                      'Como vc se sente hoje?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _symptomOptions.map((symptom) {
                        final selected = _symptoms.contains(symptom);
                        return FilterChip(
                          label: Text(symptom),
                          selected: selected,
                          checkmarkColor: Colors.white,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: selected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                          onSelected: (value) => setState(
                            () => value
                                ? _symptoms.add(symptom)
                                : _symptoms.remove(symptom),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 14),
                  const Text(
                    'O produto foi aplicado em sua propriedade?',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      OptionButton(
                        label: 'Sim',
                        selected: _appliedOnProperty == 'Sim',
                        onTap: () => setState(() => _appliedOnProperty = 'Sim'),
                      ),
                      const SizedBox(width: 8),
                      OptionButton(
                        label: 'Nao',
                        selected: _appliedOnProperty == 'Nao',
                        onTap: () => setState(() => _appliedOnProperty = 'Nao'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Quantas pessoas moram com vc?',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _peopleAtHomeController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(hintText: 'Ex.: 4'),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'O produto foi aplicado para qual cultura?',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _cropController,
                    decoration: const InputDecoration(
                      hintText: 'Ex.: cafe, milho, soja',
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedProduct,
                    decoration: const InputDecoration(
                      labelText: 'Produto utilizado',
                      hintText: 'Selecione o produto',
                    ),
                    items: _products
                        .map(
                          (product) => DropdownMenuItem(
                            value: product,
                            child: Text(product),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() {
                      _selectedProduct = value;
                      if (value != 'Outro') _productController.clear();
                    }),
                  ),
                  if (_selectedProduct == 'Outro') ...[
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Qual produto?',
                      placeholder: 'Digite o nome do produto',
                      controller: _productController,
                    ),
                  ],
                  const SizedBox(height: 14),
                  const Text(
                    'Hora:minuto',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    readOnly: true,
                    onTap: _openDurationPicker,
                    controller: _durationController,
                    decoration: const InputDecoration(
                      hintText: 'Ex.: 06:30',
                      suffixIcon: Icon(Icons.schedule),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Utilizou EPI?',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      OptionButton(
                        label: 'Sim',
                        selected: _usedPpe == 'Sim',
                        onTap: () => setState(() => _usedPpe = 'Sim'),
                      ),
                      const SizedBox(width: 8),
                      OptionButton(
                        label: 'Nao',
                        selected: _usedPpe == 'Nao',
                        onTap: () => setState(() => _usedPpe = 'Nao'),
                      ),
                      const SizedBox(width: 8),
                      OptionButton(
                        label: 'Parcial',
                        selected: _usedPpe == 'Parcial',
                        onTap: () => setState(() => _usedPpe = 'Parcial'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle(
                    title: 'Foto do rotulo (opcional)',
                    icon: Icons.photo_camera_outlined,
                  ),
                  if (_photoPath != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Foto selecionada',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  AppButton(
                    label: _photoPath == null ? 'Tirar foto' : 'Trocar foto',
                    icon: Icons.camera_alt,
                    onPressed: _pickPhoto,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: _saving ? 'Salvando...' : 'Salvar registro',
              icon: Icons.save_outlined,
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
