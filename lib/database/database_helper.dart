import 'package:mosnad_3/models/remainder_model.dart';
import 'package:mosnad_3/models/schedule_model.dart';
import 'package:mosnad_3/models/subject_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';



class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'mosnad_3.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database database, int version) async {
    await database.execute("""
          CREATE TABLE IF NOT EXISTS subjects(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            name TEXT NOT NULL
            )
          """);
    await database.execute("""
          CREATE TABLE IF NOT EXISTS schedules(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            subject_id INTEGER NOT NULL, 
            start_date INTEGER NOT NULL, 
            end_date INTEGER NOT NULL, 
            start_time TEXT NOT NULL, 
            end_time TEXT NOT NULL, 
            repeat TEXT NOT NULL,
            status TEXT NOT NULL,
            reminder_time INTEGER NOT NULL,
            FOREIGN KEY(subject_id) REFERENCES subjects (id) ON DELETE CASCADE
            )
          """);
    await database.execute("""
          CREATE TABLE IF NOT EXISTS reminders(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            schedule_id INTEGER NOT NULL, 
            day INTEGER NOT NULL, 
            FOREIGN KEY(schedule_id) REFERENCES schedules(id) ON DELETE CASCADE
            )
          """);
  }

  Future<int> insertSubject(Subject subject) async {
    final db = await database;
    return await db.insert('subjects', subject.toMap());
  }

  Future<int> insertSchedule(Schedule schedule) async {
    final db = await database;
    return await db.insert('schedules', schedule.toMap());
  }

  Future<int> insertReminder(Reminder reminder) async {
    final db = await database;
    return await db.insert('reminders', reminder.toMap());
  }

  Future<int> updateSubject(Subject subject) async {
    final db = await database;
    return await db.update('subjects', subject.toMap(), where: 'id = ?', whereArgs: [subject.id]);
  }

  Future<int> updateSchedule(Schedule schedule) async {
    final db = await database;
    return await db.update('schedules', schedule.toMap(), where: 'id = ?', whereArgs: [schedule.id]);
  }

  Future<int> updateReminder(Reminder reminder) async {
    final db = await database;
    return await db.update('reminders', reminder.toMap(), where: 'id = ?', whereArgs: [reminder.id]);
  }


  Future<Subject?> getSubjectById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('subjects', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Subject.fromMap(maps.first);
    }
    return null;
  }

  Future<Schedule?> getScheduleById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('schedules', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Schedule.fromMap(maps.first);
    }
    return null;
  }

  Future<Reminder?> getReminderById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('reminders', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Reminder.fromMap(maps.first);
    }
    return null;
  }



  Future<List<Subject>> getSubjects() async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query('subjects');
    return List.generate(maps.length, (i) {
      return Subject(
        id: maps[i]['id'],
        name: maps[i]['name'],
      );
    });
  }

  Future<List<Schedule>> getSchedules() async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query('schedules');

    List<Schedule> schedules = [];

    for (var map in maps) {
      int subjectId = map['subject_id'] as int;
      Subject? subject = await getSubjectById(subjectId);

      Schedule schedule = Schedule(
        id: map['id'],
        subjectId: subjectId,
        subject: subject, // Assign the retrieved subject to the schedule
        startDate: map['start_date'],
        endDate: map['end_date'],
        startTime: map['start_time'],
        endTime: map['end_time'],
        repeat: map['repeat'],
        status: map['status'],
        reminderTime: map['reminder_time'],
      );
      schedules.add(schedule);
    }

    return schedules;
  }
  Future<List<Reminder>> getReminders() async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query('reminders');
    return List.generate(maps.length, (i) {
      return Reminder(
        id: maps[i]['id'],
        scheduleId: maps[i]['schedule_id'],
        day: maps[i]['day'],
      );
    });
  }


  Future<void> deleteSubjectById(int id) async {
    final db = await database;
    await db.delete('subjects', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteScheduleById(int id) async {
    final db = await database;
    await db.delete('schedules', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteReminderById(int id) async {
    final db = await database;
    await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }

}
