class Schedule {
  int? id;
  int? subjectId;
  int? startDate;
  int? endDate;
  int? startTime;
  int? endTime;
  String? repeat;
  String? status;
  int? reminderTime;

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
  });

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
