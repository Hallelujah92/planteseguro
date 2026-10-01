class ParticipantModel {
  const ParticipantModel({
    required this.id,
    required this.nameOrCode,
    required this.birthDate,
    required this.sex,
    required this.municipality,
    required this.consentAccepted,
    required this.createdAt,
    this.cpf,
    this.phone,
  });

  final String id;
  final String nameOrCode;
  final String birthDate;
  final String? cpf;
  final String sex;
  final String municipality;
  final String? phone;
  final bool consentAccepted;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nameOrCode': nameOrCode,
      'birthDate': birthDate,
      'cpf': cpf,
      'sex': sex,
      'municipality': municipality,
      'phone': phone,
      'consentAccepted': consentAccepted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ParticipantModel.fromMap(Map<dynamic, dynamic> map) {
    return ParticipantModel(
      id: map['id'] as String,
      nameOrCode: map['nameOrCode'] as String,
      birthDate: (map['birthDate'] ?? map['age']?.toString() ?? '') as String,
      cpf: map['cpf'] as String?,
      sex: map['sex'] as String,
      municipality: map['municipality'] as String,
      phone: map['phone'] as String?,
      consentAccepted: map['consentAccepted'] as bool,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
