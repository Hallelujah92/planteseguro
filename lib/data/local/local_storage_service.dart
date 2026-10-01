import 'package:hive_flutter/hive_flutter.dart';

import '../models/exposure_record_model.dart';
import '../models/interview_model.dart';
import '../models/participant_model.dart';

class LocalStorageService {
  LocalStorageService._();

  static final instance = LocalStorageService._();

  static const _participantBoxName = 'participant_box';
  static const _exposureBoxName = 'exposure_records_box';
  static const _interviewBoxName = 'interviews_box';
  static const _participantKey = 'participant';

  late Box _participantBox;
  late Box _exposureBox;
  late Box _interviewBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _participantBox = await Hive.openBox(_participantBoxName);
    _exposureBox = await Hive.openBox(_exposureBoxName);
    _interviewBox = await Hive.openBox(_interviewBoxName);
  }

  Future<void> saveParticipant(ParticipantModel participant) {
    return _participantBox.put(_participantKey, participant.toMap());
  }

  ParticipantModel? getParticipant() {
    final data = _participantBox.get(_participantKey);
    if (data == null) return null;
    return ParticipantModel.fromMap(Map<dynamic, dynamic>.from(data as Map));
  }

  bool hasParticipant() => getParticipant() != null;

  Future<void> clearParticipant() {
    return _participantBox.delete(_participantKey);
  }

  Future<void> saveExposureRecord(ExposureRecordModel record) {
    return _exposureBox.put(record.id, record.toMap());
  }

  List<ExposureRecordModel> getExposureRecords() {
    final records = _exposureBox.values
        .map(
          (item) => ExposureRecordModel.fromMap(
            Map<dynamic, dynamic>.from(item as Map),
          ),
        )
        .toList();
    records.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return records;
  }

  Future<void> updateExposureRecord(ExposureRecordModel record) {
    return _exposureBox.put(record.id, record.toMap());
  }

  Future<int> markPendingRecordsAsSynced() async {
    var count = 0;
    for (final record in getExposureRecords()) {
      if (record.status == 'Pendente') {
        await updateExposureRecord(record.copyWith(status: 'Sincronizado'));
        count++;
      }
    }
    return count;
  }

  Future<void> saveInterview(InterviewModel interview) {
    return _interviewBox.put(interview.id, interview.toMap());
  }

  List<InterviewModel> getInterviews() {
    final interviews = _interviewBox.values
        .map(
          (item) =>
              InterviewModel.fromMap(Map<dynamic, dynamic>.from(item as Map)),
        )
        .toList();
    interviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return interviews;
  }

  Future<void> clearAllData() async {
    await _participantBox.clear();
    await _exposureBox.clear();
    await _interviewBox.clear();
  }
}
