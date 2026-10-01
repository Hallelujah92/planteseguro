class InterviewModel {
  const InterviewModel({
    required this.id,
    required this.participantId,
    required this.contactLast30Days,
    required this.frequency,
    required this.familyExposure,
    required this.createdAt,
    this.observations,
  });

  final String id;
  final String participantId;
  final String contactLast30Days;
  final String frequency;
  final String familyExposure;
  final String? observations;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participantId': participantId,
      'contactLast30Days': contactLast30Days,
      'frequency': frequency,
      'familyExposure': familyExposure,
      'observations': observations,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory InterviewModel.fromMap(Map<dynamic, dynamic> map) {
    return InterviewModel(
      id: map['id'] as String,
      participantId: map['participantId'] as String,
      contactLast30Days: map['contactLast30Days'] as String,
      frequency: map['frequency'] as String,
      familyExposure: map['familyExposure'] as String,
      observations: map['observations'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
