
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:mosnad_3/views/add_scedule_page.dart';
import 'package:receive_intent/receive_intent.dart';

import 'database/my_database.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

// Be sure to annotate your callback function to avoid issues in release mode on Flutter >= 3.3.0
@pragma('vm:entry-point')
Future<void> alarmHandler(int i, Map<String,dynamic> data) async {
  print('Alarm fired! $i ${DateTime.now()} with data $data}');
  try{
      // check if this a stop schedule alarm
      if(i >= 1000000){
        await AndroidAlarmManager.cancel(int.parse(data["StudyAlarmID"]));// getting the repeated alarm id, we divide by 100000 coz it was multiplied by 10
        print('Alarm ${int.parse(data["StudyAlarmID"])} Ended ${DateTime.now()}');
        return;
      }

    final int id = Isolate.current.hashCode;
      var androidInitialize =
      const AndroidInitializationSettings('mipmap/ic_launcher');
      var initializationsSettings =
      InitializationSettings(android: androidInitialize);
      flutterLocalNotificationsPlugin.initialize(initializationsSettings).then((value) {

        String title = "وقت الدراسة";
        String body = "حان وقت دراسة المادة ${data["Subject"]}";
        AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            "mosnad_defualt_channel_id",
            "mosnad",
            channelDescription: "This is my channel description",
            playSound: true,
            styleInformation: BigTextStyleInformation(body),
            additionalFlags: Int32List.fromList(<int>[4]),
            largeIcon: null,
            importance: Importance.max,
            priority: Priority.max,
            ticker: 'ticker',
            color: Colors.blue,
            colorized: true,
            category: AndroidNotificationCategory.alarm
        );
        var notification = NotificationDetails(
          android: androidNotificationDetails,
        );
        flutterLocalNotificationsPlugin.show(
            id, title, body, notification);
      });
  }catch(_){}
}
void main() async{
  // Be sure to add this line if initialize() call happens before runApp()
  WidgetsFlutterBinding.ensureInitialized();

  await AndroidAlarmManager.initialize();
  await MyDatabase.open();

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()!.requestNotificationsPermission();

    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AddSchedulePage(),
    );
  }
}
