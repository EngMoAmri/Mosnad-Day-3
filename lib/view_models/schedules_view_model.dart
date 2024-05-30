// lib/viewmodels/schedule_viewmodel.dart
import 'package:get/get.dart';
import '../models/schedule_model.dart';
import '../database//database_helper.dart';

class ScheduleViewModel extends GetxController {
  var schedules = <Schedule>[].obs;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void onInit() {
    super.onInit();
    fetchSchedules();
  }

  Future fetchSchedules() async {
    var fetchedSchedules = await _databaseHelper.getSchedules();
    schedules.value = fetchedSchedules;
  }

  void addSchedule(Schedule schedule) async {
    await _databaseHelper.insertSchedule(schedule);
    fetchSchedules();
  }


  void delete(int id) async {
    await _databaseHelper.deleteScheduleById(id);
    fetchSchedules();
  }

  void updateSchedule(Schedule schedule) async {
if(schedule.isActive){
  schedule.status=STATUS.PAUSE.name;
}else{
  schedule.status=STATUS.ACTIVE.name;
}
  await _databaseHelper.updateSchedule(schedule);
    fetchSchedules();
  }

}
