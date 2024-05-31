import 'package:flutter/material.dart';
import 'package:get/get.dart';


Container subHeaderwidget(
    {
    String title = 'الجدولة',
    required double width,
    required Widget cheild,
    Widget? printWidget}) {

  return Container(
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(
          horizontal: width / 20, vertical:Get.height * 0.01),
      child: Column(children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(child: subheading(title)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (printWidget != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: printWidget,
                  ),
                GestureDetector(
                  onTap: ()  {
                  Get.to(cheild);},
                  child: addIcon(),
                ),
              ],
            ),
          ],
        ),
      ]));
}

Text subheading(String title, {double fontSize = 20.0}) {
  return Text(
    title,
    style: TextStyle(
        color: const Color.fromRGBO(94, 114, 228, 1.0),
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2),
  );
}

CircleAvatar addIcon() {
  return const CircleAvatar(
    radius: 25.0,
    backgroundColor: Color.fromRGBO(94, 114, 228, 1.0),
    child: Icon(
      Icons.add,
      size: 20.0,
      color: Colors.white,
    ),
  );
}
