import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:mosnad_3/view_models/add_schedule_view_model.dart';

class AddSchedulePage extends StatelessWidget {
  const AddSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Get.put(AddScheduleViewModel());
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title:  const Text("إضافة جدولة",
            style:TextStyle(fontWeight: FontWeight.bold),),
          centerTitle: true,
        ),
        body: Column(
          children: [
            const Divider(height: 1,),
            Expanded(
              child: Form(
                key: viewModel.formKey,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child:
                    LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 480) {
                            return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 480,
                                    child: addForm(viewModel,context),
                                  ),]);
                          }
                          return addForm(viewModel,context);
                        }

                    ),


                  ),
                ),
              ),
            ),
          ],
        ),

      ),
    );
  }

  Widget addForm(AddScheduleViewModel modelView, context){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: modelView.subjectNameController,
          decoration: const InputDecoration(
              hintText: "اسم المادة"
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return 'هذا الحقل مطلوب';
            }
            return null;
          },

        ),
        TextFormField(
          onTap: (){
            modelView.selectDate(context).then((value) {
              if(value==null){
                return;
              }
              modelView.startDate.value = value;
              String formattedDate = intl.DateFormat('dd/MM/yyyy').format(value);
              modelView.startDateController.text = formattedDate;
            });
          },
          readOnly: true,
          controller: modelView.startDateController,
          decoration: const InputDecoration(
              hintText: "تأريخ البدأ"
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return 'هذا الحقل مطلوب';
            }
            return null;
          },

        ),
        TextFormField(
          onTap: (){
            if(modelView.startDate.value==null){
              Get.showSnackbar(const GetSnackBar(titleText: Text("ملاحظة"), message: "يجب عليك إختيار تأريخ البدأ أولاً", duration: Duration(seconds: 3),),);
              return;
            }
            modelView.selectDate(context, start:  modelView.startDate.value).then((value) {
              if(value==null){
                return;
              }
              modelView.endDate.value = value;
              String formattedDate = intl.DateFormat('dd/MM/yyyy').format(value);
              modelView.endDateController.text = formattedDate;
            });
          },
          readOnly: true,
          controller: modelView.endDateController,
          decoration: const InputDecoration(
              hintText: "تأريخ الإنتهاء"
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return 'هذا الحقل مطلوب';
            }
            return null;
          },

        ),
        TextFormField(
          onTap: (){
            modelView.selectTime(context).then((value) {
              if(value==null){
                return;
              }

              modelView.startTimeController.text = "${value.hour}:${value.minute}";
            });
          },
          readOnly: true,
          controller: modelView.startTimeController,
          decoration: const InputDecoration(
              hintText: "وقت البدأ"
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return 'هذا الحقل مطلوب';
            }
            return null;
          },

        ),
        TextFormField(
          onTap: (){

            if(modelView.startTimeController.text.trim().isEmpty){
              Get.showSnackbar(const GetSnackBar(titleText: Text("ملاحظة"), message: "يجب عليك إختيار وقت البدأ أولاً", duration: Duration(seconds: 3),),);
              return;
            }
            modelView.selectTime(context).then((value) {
              if(value==null){
                return;
              }

              modelView.endTimeController.text =  "${value.hour}:${value.minute}";
            });
          },
          readOnly: true,
          controller: modelView.endTimeController,
          decoration: const InputDecoration(
              hintText: "وقت الإنتهاء"
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return 'هذا الحقل مطلوب';
            }
            return null;
          },
        ),
        const SizedBox(height: 10,),
        const Text("التكرار",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
        Obx(() =>
            ListView(
              shrinkWrap: true,
              children: <Widget>[
                RadioListTile(
                  title: const Text('كل يوم'),
                  value: 1,
                  groupValue:
                  modelView.repeat.value,
                  onChanged: (value) {
                    modelView.repeat.value = value!;
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile(
                        title: const Text('أيام محددة'),
                        subtitle: Text(modelView.getSelectedDays()),
                        value: 2,
                        groupValue:
                        modelView.repeat.value,
                        onChanged: (value) {
                          modelView.repeat.value = value!;
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: (){
                        showModalBottomSheet(
                            context: context,
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            builder: (BuildContext context) {
                              return Obx(() =>
                                  ListView(
                                    shrinkWrap: true,
                                    children: <Widget>[
                                      CheckboxListTile(
                                        title: const Text('السبت'),
                                        value: modelView.days.value[0],
                                        onChanged: (value) {
                                          modelView.days.value[0] = value!;
                                          modelView.days.refresh();
                                        },
                                      ),
                                      CheckboxListTile(
                                        title: const Text('الأحد'),
                                        value: modelView.days.value[1],
                                        onChanged: (value) {
                                          modelView.days.value[1] = value!;
                                          modelView.days.refresh();
                                        },
                                      ),
                                      CheckboxListTile(
                                        title: const Text('الإثنين'),
                                        value: modelView.days.value[2],
                                        onChanged: (value) {
                                          modelView.days.value[2] = value!;
                                          modelView.days.refresh();
                                        },
                                      ),
                                      CheckboxListTile(
                                        title: const Text('الثلاثاء'),
                                        value: modelView.days.value[3],
                                        onChanged: (value) {
                                          modelView.days.value[3] = value!;
                                          modelView.days.refresh();
                                        },
                                      ),
                                      CheckboxListTile(
                                        title: const Text('الأربعاء'),
                                        value: modelView.days.value[4],
                                        onChanged: (value) {
                                          modelView.days.value[4] = value!;
                                          modelView.days.refresh();
                                        },
                                      ),
                                      CheckboxListTile(
                                        title: const Text('الخميس'),
                                        value: modelView.days.value[5],
                                        onChanged: (value) {
                                          modelView.days.value[5] = value!;
                                          modelView.days.refresh();
                                        },
                                      ),
                                      CheckboxListTile(
                                        title: const Text('الحمعة'),
                                        value: modelView.days.value[6],
                                        onChanged: (value) {
                                          modelView.days.value[6] = value!;
                                          modelView.days.refresh();
                                        },
                                      ),
                                    ],
                                  )

                              );
                            });
                      },
                        icon: const Icon(Icons.settings))
                  ],
                ),
              ],
            ),
        ),
        const SizedBox(height: 10,),

        const Text("الدقائق قبل التذكير",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Obx(() =>
          DropdownButton(
            value: modelView.reminderTimeValue.value,
            icon: const Icon(Icons.keyboard_arrow_down),
            items: modelView.reminderTimes.map((String time) {
              return DropdownMenuItem(
                value: time,
                child: Text(time),
              );
            }).toList(),
            onChanged: (newValue) {
              modelView.reminderTimeValue.value = newValue!;
            },
              ),
          ),
        ),
        const SizedBox(height: 10,),
        Obx(() =>
        modelView.saving.value?
        const Center(child: CircularProgressIndicator(),)
            :
        ElevatedButton(
            style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.black),
            onPressed: ()=>
                modelView.addSchedule(), child: const Text("إضافة"))
        )
      ],
    );
  }
}
