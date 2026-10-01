import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_text_field.dart';
import '../../data/local/local_storage_service.dart';
import '../../data/models/participant_model.dart';
import '../home/home_screen.dart';

class ParticipantFormScreen extends StatefulWidget {
  const ParticipantFormScreen({super.key});

  @override
  State<ParticipantFormScreen> createState() => _ParticipantFormScreenState();
}

class _ParticipantFormScreenState extends State<ParticipantFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _cpfController = TextEditingController();
  final _municipalityController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _sex;
  bool _consentAccepted = false;

  String? _validateCpf(String? value) {
    final cpf = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (cpf.isEmpty) return null;
    if (cpf.length != 11) return 'O CPF deve ter 11 numeros.';
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cpf)) return 'Informe um CPF valido.';

    int calculateDigit(String digits, int initialWeight) {
      var sum = 0;
      for (var index = 0; index < digits.length; index++) {
        sum += int.parse(digits[index]) * (initialWeight - index);
      }
      final remainder = sum % 11;
      return remainder < 2 ? 0 : 11 - remainder;
    }

    final firstDigit = calculateDigit(cpf.substring(0, 9), 10);
    final secondDigit = calculateDigit(cpf.substring(0, 10), 11);
    if (firstDigit != int.parse(cpf[9]) || secondDigit != int.parse(cpf[10])) {
      return 'Informe um CPF valido.';
    }
    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _cpfController.dispose();
    _municipalityController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid || !_consentAccepted) {
      if (!_consentAccepted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('O termo de consentimento deve ser aceito.'),
          ),
        );
      }
      return;
    }

    final now = DateTime.now();
    final participant = ParticipantModel(
      id: 'participant_${now.microsecondsSinceEpoch}',
      nameOrCode: _nameController.text.trim(),
      birthDate: _birthDateController.text.trim(),
      cpf: _cpfController.text.trim().isEmpty
          ? null
          : _cpfController.text.trim(),
      sex: _sex!,
      municipality: _municipalityController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      consentAccepted: _consentAccepted,
      createdAt: now,
    );
    await LocalStorageService.instance.saveParticipant(participant);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Selecione a data de nascimento',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );
    if (picked != null) {
      _birthDateController.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro inicial')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: AppCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    label: 'Nome',
                    placeholder: 'Nome',
                    controller: _nameController,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Informe o nome.'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _birthDateController,
                    readOnly: true,
                    onTap: _pickBirthDate,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Informe a data de nascimento.'
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Data de nascimento',
                      hintText: 'Selecione a data',
                      suffixIcon: Icon(Icons.calendar_month),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'CPF',
                    placeholder: 'Digite somente numeros',
                    controller: _cpfController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(11),
                    ],
                    validator: _validateCpf,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _sex,
                    decoration: const InputDecoration(
                      labelText: 'Sexo',
                      hintText: 'Selecione',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Masculino',
                        child: Text('Masculino'),
                      ),
                      DropdownMenuItem(
                        value: 'Feminino',
                        child: Text('Feminino'),
                      ),
                      DropdownMenuItem(value: 'Outro', child: Text('Outro')),
                      DropdownMenuItem(
                        value: 'Prefere nao informar',
                        child: Text('Prefere nao informar'),
                      ),
                    ],
                    onChanged: (value) => setState(() => _sex = value),
                    validator: (value) =>
                        value == null ? 'Selecione o sexo.' : null,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Municipio',
                    placeholder: 'Informe seu municipio',
                    controller: _municipalityController,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Informe o municipio.'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Telefone (opcional)',
                    placeholder: '(00) 00000-0000',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    value: _consentAccepted,
                    onChanged: (value) =>
                        setState(() => _consentAccepted = value ?? false),
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.primary,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: const Text(
                      'Li e concordo com o termo de consentimento',
                    ),
                  ),
                  const SizedBox(height: 10),
                  AppButton(
                    label: 'Salvar cadastro',
                    icon: Icons.save_outlined,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
