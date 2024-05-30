import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showDeleteDialog({required String title, required Function() onPressed}) {
  Get.defaultDialog(
    titleStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    title: 'هل انت متأكد من حذف $title ؟',
    content: Column(
      children: [
        SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: onPressed,
              child: Text('موافق'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
              },
              child: Text('الغاء'),
            ),
          ],
        ),
      ],
    ),
    barrierDismissible: false,
  );
}