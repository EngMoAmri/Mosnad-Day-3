import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mosnad_3/database/database_helper.dart';
import 'package:mosnad_3/main.dart';
import 'package:mosnad_3/models/remainder_model.dart';
import 'package:mosnad_3/models/schedule_model.dart';
import 'package:mosnad_3/models/subject_model.dart';
import 'package:mosnad_3/views/dialogs/action_dialog.dart';
import 'package:permission_handler/permission_handler.dart';

class AddScheduleViewModel extends GetxController {
  var saving = false.obs;
  final formKey = GlobalKey<FormState>();
  final subjectNameController = TextEditingController();
  final startDateController = TextEditingController();
  Rx<DateTime?> startDate = Rx(null);
  final endDateController = TextEditingController();
  Rx<DateTime?> endDate = Rx(null);
  final startTimeController = TextEditingController();
  final endTimeController = TextEditingController();
  var repeat = 1.obs;
  Rx<List<bool>> days = Rx([false, false, false, false, false, false, false]);
  var reminderTimeValue = '5'.obs;
  var reminderTimes = [
    '5',
    '10',
    '15',
  ];

  Future<DateTime?> selectDate(context,{DateTime? start}) async {
    return await showDatePicker(
      context: context,
      initialDate: start??DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light(),
          child: child!,
        );
      },
    );
  }
  Future<TimeOfDay?> selectTime(context) async {
    return await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: ThemeData.light(),
            child: child!,
          );
        });

  }

  String getSelectedDays(){
    List<String> daysNames = ["السبت", "الأحد", "الإثنان", "الثلاثاء", "الأربعاء", "الخميس", "الجمعة"];
    var selectedDays = "";
    for(var day in daysNames){
      if(days.value[daysNames.indexOf(day)]){
        selectedDays = "$selectedDays[$day]";
      }
    }
    return selectedDays;
  }
  void addSchedule(context) async{
    if(!formKey.currentState!.validate()){
      return;
    }
    // checking if there is conflict
    var schedules = await DatabaseHelper().getSchedules();
    var schedule = Schedule(
        startDate: startDate.value!.millisecondsSinceEpoch,
        endDate: endDate.value!.millisecondsSinceEpoch,
        startTime: startTimeController.text,
        endTime: endTimeController.text,
        repeat: repeat.value==1?"daily":"specific",
        status: "active",
        reminderTime: int.parse(reminderTimeValue.value)
    );
    for(var s in schedules){
      if((s.startDate! <= schedule.endDate!) && (s.endDate! >= schedule.startDate!)){
        var aStartTime = TimeOfDay(hour:  int.parse(s.startTime!.split(":")[0]),minute:  int.parse(s.startTime!.split(":")[1]));
        var bStartTime = TimeOfDay(hour:  int.parse(schedule.startTime!.split(":")[0]),minute:  int.parse(schedule.startTime!.split(":")[1]));
        var aEndTime = TimeOfDay(hour:  int.parse(s.endTime!.split(":")[0]),minute:  int.parse(s.endTime!.split(":")[1]));
        var bEndTime = TimeOfDay(hour:  int.parse(schedule.endTime!.split(":")[0]),minute:  int.parse(schedule.endTime!.split(":")[1]));
        if(toDouble(aStartTime)<=toDouble(bEndTime)&&toDouble(aEndTime)>=toDouble(bStartTime)){
          if(await showActionDialog(context, "يوجد تعارض مع جدول آخر هل تريد الإضافة") == false){
            return;
          }
        }
      }
    }
    print("no");
    saving.value = true;
    // Add to local database then
    var subject=Subject(name:  subjectNameController.text);
    subject.id = await DatabaseHelper().insertSubject(subject);
    schedule.subjectId = subject.id;

    schedule.id = await DatabaseHelper().insertSchedule(schedule);
    if(repeat.value==2){
      List<String> daysNames = ["السبت", "الأحد", "الإثنان", "الثلاثاء", "الأربعاء", "الخميس", "الجمعة"];
      for(var day in daysNames){
        if(days.value[daysNames.indexOf(day)]){
          await DatabaseHelper().insertReminder(Reminder(scheduleId: schedule.id, day: daysNames.indexOf(day)));
        }
      }
    }
    int scheduleId = 0;// get the id from the database
    var startDateTime = DateTime(startDate.value!.year,startDate.value!.month,startDate.value!.day,
        int.parse(startTimeController.text.split(":")[0]), int.parse(startTimeController.text.split(":")[1]));
    if(repeat.value == 1){
      AndroidAlarmManager.periodic(const Duration(days: 1),
          scheduleId*10,// we multiply by 10 to avoid conflicts with specifics days alarms
          alarmHandler,
          //                     to make the app reminds the user before the study time
          startAt: startDateTime.subtract(Duration(minutes: int.parse(reminderTimeValue.value))),
          allowWhileIdle: true,
          exact: (await Permission.scheduleExactAlarm.request()).isGranted,
          wakeup: true,
          rescheduleOnReboot: true,
          params: {
            "Subject": subjectNameController.text,
          }
      );
      // set an alarm to stop or cancel the alarm at the end date
      AndroidAlarmManager.oneShotAt(endDate.value!,
          scheduleId+1000000,// to avoid conflicts with study alarms
          alarmHandler,
          allowWhileIdle: true,
          exact: (await Permission.scheduleExactAlarm.request()).isGranted,
          wakeup: true,
          rescheduleOnReboot: true,
          params: {
            "StudyAlarmID": "${scheduleId*10}",
          }
      );

    }else{
      int day = 0;
      while(day < 7) {
        if(days.value[day]) {
          AndroidAlarmManager.periodic(
              const Duration(days: 8),
              (scheduleId*10)+day, // here we jus add the day index
              alarmHandler,
              //                               to make the app reminds the user before the study time
              startAt: startDateTime.next(day).subtract(Duration(minutes: int.parse(reminderTimeValue.value))),
              allowWhileIdle: true,
              exact: (await Permission.scheduleExactAlarm.request()).isGranted,
              wakeup: true,
              rescheduleOnReboot: true,
              params: {
                "Subject": subjectNameController.text,
              });
          // set an alarm to stop or cancel the alarm at the end date
          AndroidAlarmManager.oneShotAt(endDate.value!,
              ((scheduleId*10)+day)*1000000,// to avoid conflicts with study alarms
              alarmHandler,
              allowWhileIdle: true,
              exact: (await Permission.scheduleExactAlarm.request()).isGranted,
              wakeup: true,
              rescheduleOnReboot: true,
              params: {
                "StudyAlarmID": "${(scheduleId*10)+day}",
              }
          );

        }
        day++;
      }
    }
    saving.value = false;
    Get.back(result: true);
  }

  // void testAddSchedule() async{
  //   saving.value = true;
  //
  //   // Add to local database then
  //
  //   int scheduleId = 1;// get the id from the database
  //   var startDateTime = DateTime.now();
  //   if(repeat.value == 1){
  //     AndroidAlarmManager.periodic(const Duration(seconds: 10),
  //         scheduleId*10,// we multiply by 10 to avoid conflicts with specifics days alarms
  //         alarmHandler,
  //         startAt: startDateTime.add(const Duration(seconds: 3)),
  //         allowWhileIdle: true,
  //         exact: true,
  //         wakeup: true,
  //         rescheduleOnReboot: true,
  //         params: {
  //           "Subject": subjectNameController.text,
  //         }
  //     );
  //     // set an alarm to stop or cancel the alarm at the end date
  //     AndroidAlarmManager.oneShotAt(startDateTime.add(const Duration(minutes: 2)),
  //         (scheduleId*10)+1000000,// to avoid conflicts with study alarms
  //         alarmHandler,
  //         allowWhileIdle: true,
  //         exact: true,
  //         wakeup: true,
  //         rescheduleOnReboot: true,
  //         params: {
  //           "StudyAlarmID": "${scheduleId*10}",
  //         }
  //     );
  //
  //   }else{
  //     int part = 0;
  //     while(part < 6) {
  //       if(part % 2 == 1) {
  //         AndroidAlarmManager.periodic(
  //             const Duration(minutes: 1),
  //             (scheduleId*10)+part, // here we jus add the day index
  //             alarmHandler,
  //             startAt: startDateTime.add(Duration(seconds: part*10)),
  //             allowWhileIdle: true,
  //             exact: true,
  //             wakeup: true,
  //             rescheduleOnReboot: true,
  //             params: {
  //               "Subject": subjectNameController.text,
  //             });
  //         // set an alarm to stop or cancel the alarm at the end date
  //         AndroidAlarmManager.oneShotAt(endDate.value!,
  //             ((scheduleId*10)+part)*1000000,// to avoid conflicts with study alarms
  //             alarmHandler,
  //             allowWhileIdle: true,
  //             exact: true,
  //             wakeup: true,
  //             rescheduleOnReboot: true,
  //             params: {
  //               "StudyAlarmID": "${(scheduleId*10)+part}",
  //             }
  //         );
  //
  //       }
  //       part++;
  //     }
  //   }
  //   saving.value = false;
  //
  // }
}
// extension to find the next day datetime
extension DateTimeExtension on DateTime {
  DateTime next(int day) {
    return add(
      Duration(
        days: (day - weekday) % DateTime.daysPerWeek,
      ),
    );
  }
}
double toDouble(TimeOfDay myTime) => myTime.hour + myTime.minute/60.0;