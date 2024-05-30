import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mosnad_3/main.dart';
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
  void addSchedule() async{
    if(!formKey.currentState!.validate()){
      return;
    }
    saving.value = true;
    // Add to local database then

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


        }
        day++;
      }
    }
    saving.value = false;

  }


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