import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class MyDatabase {
  static Database? myDatabase;

  static bool isInitialized() => myDatabase != null;

  static Future<Database> open() async {
    // Avoid errors caused by flutter upgrade.
    // Importing 'package:flutter/widgets.dart' is required.
    WidgetsFlutterBinding.ensureInitialized();
    // Open the database and store the reference.
    myDatabase = await openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'mosnad_3.db'),
      // When the database is first created, create tables.
      onCreate: (database, version) async {
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
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );

    return myDatabase!;
  }

  static Future close() async => MyDatabase.myDatabase!.close();
}