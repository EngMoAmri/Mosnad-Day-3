
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:mosnad_3/database/mock_data_helper.dart';
import 'package:mosnad_3/views/add_scedule_page.dart';
import 'package:mosnad_3/views/schedules_veiw.dart';

import 'database/my_database.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

// Be sure to annotate your callback function to avoid issues in release mode on Flutter >= 3.3.0
@pragma('vm:entry-point')
alarmHandler() async {
  try{
    // TODO check if the alarm period is ended
    final int id = Isolate.current.hashCode;
      var androidInitialize =
      const AndroidInitializationSettings('mipmap/ic_launcher');
      var initializationsSettings =
      InitializationSettings(android: androidInitialize);
      await flutterLocalNotificationsPlugin.initialize(initializationsSettings);
      String title = "وقت الدراسة";
      String body = "حان وقت الدراسة";
      AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
        "mosnad_defualt_channel_id",
        "mosnad",
        channelDescription: "This is my channel description",
        playSound: true,
        styleInformation: BigTextStyleInformation(body),
        largeIcon: null,
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'ticker',
        color: Colors.blue,
        colorized: true,
        category: AndroidNotificationCategory.alarm
      );
      var notification = NotificationDetails(
        android: androidNotificationDetails,
      );
      await flutterLocalNotificationsPlugin.show(
          id, title, body, notification);
    // }
  }catch(_){}
}
void main() async{
  // Be sure to add this line if initialize() call happens before runApp()
  WidgetsFlutterBinding.ensureInitialized();

  // await MockDataHelper().init();
  await AndroidAlarmManager.initialize();
  await MyDatabase.open();
  //
  // final receivedIntent = await ReceiveIntent.getInitialIntent();
  // if (receivedIntent?.action == "android.intent.action.MAIN"){
  //   print("1");
  //   final id = receivedIntent?.extra?["id"];
  //   final paramsExtra = receivedIntent?.extra?["params"];
  //   Map<String, dynamic> params;
  //   if (paramsExtra != null){
  //     // The received params is a string, so we need to convert it into a json map
  //     params = jsonDecode(paramsExtra);
  //   }else{
  //     return;
  //   }
  //   print("2");
  //   // check if this a stop schedule alarm
  //   if(id >= 1000000){
  //     await AndroidAlarmManager.cancel(int.parse(params["StudyAlarmID"]));// getting the repeated alarm id, we divide by 100000 coz it was multiplied by 10
  //     return;
  //   }
  //   print("3");

  runApp(const MyApp());

}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()!.requestNotificationsPermission();

    return GetMaterialApp(
      title: '',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurpleAccent),
        useMaterial3: true,
      ),
      home:  SchedulesView(),
    );
  }
}
