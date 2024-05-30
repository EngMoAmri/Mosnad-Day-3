import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/remainder_model.dart';
import '../models/schedule_model.dart';
import '../models/subject_model.dart';

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
    return List.generate(maps.length, (i) {
      return Schedule(
        id: maps[i]['id'],
        subjectId: maps[i]['subject_id'],
        startDate: maps[i]['start_date'],
        endDate: maps[i]['end_date'],
        startTime: maps[i]['start_time'],
        endTime: maps[i]['end_time'],
        repeat: maps[i]['repeat'],
        status: maps[i]['status'],
        reminderTime: maps[i]['reminder_time'],
      );
    });
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
}
