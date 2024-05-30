class Reminder {
  int? id;
  int? scheduleId;
  int? day;

  Reminder({
    this.id,
    this.scheduleId,
    this.day,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'schedule_id': scheduleId,
      'day': day,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      scheduleId: map['schedule_id'],
      day: map['day'],
    );
  }
}
