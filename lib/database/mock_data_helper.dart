import 'dart:math';

import 'database_helper.dart';
import 'package:mosnad_3/models/remainder_model.dart';
import 'package:mosnad_3/models/schedule_model.dart';
import 'package:mosnad_3/models/subject_model.dart';

class MockDataHelper {
   final dbLocal = DatabaseHelper();

   Future<void> init() async {
    List<Subject> mockSubjects = createMockSubjects(5);
    List<Schedule> mockSchedules = createMockSchedules(5, mockSubjects);
    List<Reminder> mockReminders = createMockReminders(5, mockSchedules);

    // Printing mock data for demonstration
    print('Mock Subjects:');
    for (var subject in mockSubjects) {
      dbLocal.insertSubject(subject);
      print(subject.toMap());
    }

    print('\nMock Schedules:');
    for (var schedule in mockSchedules) {
      dbLocal.insertSchedule(schedule);
      print(schedule.toMap());
    }

    print('\nMock Reminders:');
    for (var reminder in mockReminders) {
      dbLocal.insertReminder(reminder);
      print(reminder.toMap());
    }
  }

  static List<Subject> createMockSubjects(int count) {
    List<String> subjectNames = ['Math', 'Science', 'History', 'Art', 'Music'];
    List<Subject> subjects = [];

    for (int i = 0; i < count; i++) {
      subjects.add(
        Subject(
          id: i + 1,
          name: subjectNames[Random().nextInt(subjectNames.length)],
        ),
      );
    }

    return subjects;
  }

  static List<Schedule> createMockSchedules(int count, List<Subject> subjects) {
    List<String> repeats = ['None', 'Daily', 'Weekly', 'Monthly'];
    List<String> statuses = [STATUS.ACTIVE.name,STATUS.PAUSE.name];
    List<Schedule> schedules = [];

    for (int i = 0; i < count; i++) {
      schedules.add(
        Schedule(
          id: i + 1,
          subjectId: subjects[Random().nextInt(subjects.length)].id,
          startDate: DateTime.now().millisecondsSinceEpoch,
          endDate: DateTime.now()
              .add(Duration(days: Random().nextInt(10)))
              .millisecondsSinceEpoch,
          startTime:
              '${Random().nextInt(24).toString().padLeft(2, '0')}:${Random().nextInt(60).toString().padLeft(2, '0')}',
          endTime:
              '${Random().nextInt(24).toString().padLeft(2, '0')}:${Random().nextInt(60).toString().padLeft(2, '0')}',
          repeat: repeats[Random().nextInt(repeats.length)],
          status: statuses[Random().nextInt(statuses.length)],
          reminderTime: Random().nextInt(60),
        ),
      );
    }

    return schedules;
  }

  static List<Reminder> createMockReminders(
      int count, List<Schedule> schedules) {
    List<Reminder> reminders = [];

    for (int i = 0; i < count; i++) {
      reminders.add(
        Reminder(
          id: i + 1,
          scheduleId: schedules[Random().nextInt(schedules.length)].id,
          day: Random().nextInt(7) + 1, // Day of the week (1-7)
        ),
      );
    }

    return reminders;
  }
}
