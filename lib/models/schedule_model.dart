import 'package:mosnad_3/models/subject_model.dart';

enum STATUS {
  ACTIVE,
  PAUSE
}
class Schedule {
  int? id;
  int? subjectId;
  int? startDate;
  int? endDate;
  String? startTime;
  String? endTime;
  String? repeat;
  String? status=STATUS.ACTIVE.name;
  int? reminderTime;
  Subject? subject;

  Schedule({
    this.id,
    this.subjectId,
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.repeat,
    this.status,
    this.reminderTime,
    this.subject
  });

  get isActive => status==STATUS.ACTIVE.name;
  get isPause => status==STATUS.PAUSE.name;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject_id': subjectId,
      'start_date': startDate,
      'end_date': endDate,
      'start_time': startTime,
      'end_time': endTime,
      'repeat': repeat,
      'status': status,
      'reminder_time': reminderTime,
    };
  }

  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      id: map['id'],
      subjectId: map['subject_id'],
      startDate: map['start_date'],
      endDate: map['end_date'],
      startTime: map['start_time'],
      endTime: map['end_time'],
      repeat: map['repeat'],
      status: map['status'],
      reminderTime: map['reminder_time'],
    );
  }
}
