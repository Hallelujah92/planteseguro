class ExposureRecordModel {
  const ExposureRecordModel({
    required this.id,
    required this.participantId,
    required this.date,
    required this.time,
    required this.crop,
    required this.productName,
    required this.exposureTime,
    required this.usedPpe,
    required this.hadSymptoms,
    required this.symptoms,
    required this.status,
    required this.createdAt,
    this.latitude,
    this.longitude,
    this.howFeelToday,
    this.appliedOnProperty,
    this.peopleAtHome,
    this.observations,
    this.photoPath,
  });

  final String id;
  final String participantId;
  final String date;
  final String time;
  final double? latitude;
  final double? longitude;
  final String crop;
  final String productName;
  final String exposureTime;
  final String usedPpe;
  final bool? hadSymptoms;
  final String? howFeelToday;
  final String? appliedOnProperty;
  final int? peopleAtHome;
  final List<String> symptoms;
  final String? observations;
  final String? photoPath;
  final String status;
  final DateTime createdAt;

  ExposureRecordModel copyWith({String? status}) {
    return ExposureRecordModel(
      id: id,
      participantId: participantId,
      date: date,
      time: time,
      latitude: latitude,
      longitude: longitude,
      crop: crop,
      productName: productName,
      exposureTime: exposureTime,
      usedPpe: usedPpe,
      hadSymptoms: hadSymptoms,
      howFeelToday: howFeelToday,
      appliedOnProperty: appliedOnProperty,
      peopleAtHome: peopleAtHome,
      symptoms: symptoms,
      observations: observations,
      photoPath: photoPath,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participantId': participantId,
      'date': date,
      'time': time,
      'latitude': latitude,
      'longitude': longitude,
      'crop': crop,
      'productName': productName,
      'exposureTime': exposureTime,
      'usedPpe': usedPpe,
      'hadSymptoms': hadSymptoms,
      'howFeelToday': howFeelToday,
      'appliedOnProperty': appliedOnProperty,
      'peopleAtHome': peopleAtHome,
      'symptoms': symptoms,
      'observations': observations,
      'photoPath': photoPath,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ExposureRecordModel.fromMap(Map<dynamic, dynamic> map) {
    return ExposureRecordModel(
      id: map['id'] as String,
      participantId: map['participantId'] as String,
      date: map['date'] as String,
      time: map['time'] as String,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      crop: map['crop'] as String,
      productName: map['productName'] as String,
      exposureTime: map['exposureTime'] as String,
      usedPpe: map['usedPpe'] as String,
      hadSymptoms: map['hadSymptoms'] as bool?,
      howFeelToday: map['howFeelToday'] as String?,
      appliedOnProperty: map['appliedOnProperty'] as String?,
      peopleAtHome: map['peopleAtHome'] as int?,
      symptoms: List<String>.from(map['symptoms'] as List? ?? const []),
      observations: map['observations'] as String?,
      photoPath: map['photoPath'] as String?,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
