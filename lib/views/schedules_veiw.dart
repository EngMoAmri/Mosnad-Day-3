// lib/views/schedule_view.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mosnad_3/global_widgets/delete_dialog.dart';
import 'package:mosnad_3/global_widgets/headerwidget.dart';
import 'package:mosnad_3/global_widgets/top_container.dart';
import 'package:mosnad_3/view_models/schedules_view_model.dart';
import 'package:mosnad_3/views/add_scedule_page.dart';

class SchedulesView extends StatelessWidget {
  final ScheduleViewModel viewModel = Get.put(ScheduleViewModel());

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Obx(() {
        if (viewModel.schedules.isEmpty) {
          return Center(child: Text('No schedules available'));
        } else {
          return SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    SizedBox(height: 70),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: viewModel.fetchSchedules,
                        child: ListView.builder(
                          primary: true,
                          shrinkWrap: true,
                          padding: EdgeInsets.all(8.0),
                          itemCount: viewModel.schedules.length,
                          itemBuilder: (context, index) {
                            final schedule = viewModel.schedules[index];
                            return Stack(
                              alignment: AlignmentDirectional.centerEnd,
                              children: [
                                Card(
                                  color:schedule.isPause?Colors.black12: Colors.amber[20],
                                  elevation: 4,
                                  margin: EdgeInsets.symmetric(vertical: 5.0),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.all(16.0),
                                    title: Text(
                                      ' ${schedule.subject?.name ?? ""}',
                                      style: TextStyle(
                                          fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 8.0),
                                        Text(
                                            'Start: ${formatDateTime(schedule.startDate!, schedule.startTime!)}'),
                                        Text(
                                            'End: ${formatDateTime(schedule.endDate!, schedule.endTime!)}'),
                                        SizedBox(height: 8.0),
                                        buildStatusWidget(
                                            schedule.startDate!,
                                            schedule.startTime!,
                                            schedule.endDate!,
                                            schedule.endTime!),
                                        SizedBox(height: 8.0),
                                        Text(
                                            'Reminder: ${schedule.reminderTime} minutes before'),
                                      ],
                                    ),
                                  ),
                                ),
                                Column(
                                  children: [
                                    defIconButton(icon: Icons.edit, onPressed: (){
                                    }),
                                    defIconButton(icon: Icons.delete_forever_rounded,color: Colors.redAccent, onPressed: (){
                                      showDeleteDialog(title: "هذا الجدول", onPressed: (){
                                        viewModel.delete(schedule.id!);
                                        Get.back();
                                      });
                                    }),
                                    defIconButton(icon:schedule.isActive? Icons.alarm_on_rounded:Icons.alarm_off_rounded, onPressed: (){
                                      viewModel.updateSchedule(schedule);
                                    }),
                                  ],
                                )
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const Stack(
                  alignment: AlignmentDirectional.centerEnd,
                  children: [
                    TopContainer(isBackButton: false,),
        //             Row(
        // mainAxisAlignment : MainAxisAlignment.end,
        //               children: [
        //                 FloatingActionButton(
        //                   onPressed: () {
        //                     Get.to(AddSchedulePage()); // Navigates to AddSchedulePage
        //                   },
        //                   child: Icon(Icons.add),
        //                 ),
        //               SizedBox(width: 20,)
        //               ],
        //             ),
                  ],
                ),

              ],
            ),
          );
        }
      }),
      floatingActionButton:   FloatingActionButton(
        onPressed: () {
          Get.to(AddSchedulePage())?.then((value) {
            print("added $value");
            if(value==true){
              viewModel.fetchSchedules();
            }
          }); // Navigates to AddSchedulePage
        },
        child: Icon(Icons.add),
      ),

    );
  }

  Widget defIconButton(
      {required IconData icon,
      required Function()? onPressed,
      Color? color,
      double width = 50,
      double height = 50}) {
    return SizedBox(
        height: height,
        width: width,
        child: Card(
            color: Colors.amber[50],
            child: IconButton(
                onPressed: onPressed,
                padding: EdgeInsets.zero,
                icon: Icon(icon, color: color))));
  }

  String formatDateTime(int date, String time) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(date);
    return DateFormat('yyyy-MM-dd – kk:mm').format(dateTime) + ' at ' + time;
  }

  Widget buildStatusWidget(
      int startDate, String startTime, int endDate, String endTime) {
    final now = DateTime.now();
    final startDateTime = DateTime.fromMillisecondsSinceEpoch(startDate).add(
        Duration(
            hours: int.parse(startTime.split(':')[0]),
            minutes: int.parse(startTime.split(':')[1])));
    final endDateTime = DateTime.fromMillisecondsSinceEpoch(endDate).add(
        Duration(
            hours: int.parse(endTime.split(':')[0]),
            minutes: int.parse(endTime.split(':')[1])));

    if (now.isBefore(startDateTime)) {
      final difference = startDateTime.difference(now);
      return Text(
          'Starting after ${difference.inHours} hours ${difference.inMinutes.remainder(60)} minutes');
    } else if (now.isAfter(endDateTime)) {
      return Text('Completed');
    } else {
      return Text('In Progress');
    }
  }
}
