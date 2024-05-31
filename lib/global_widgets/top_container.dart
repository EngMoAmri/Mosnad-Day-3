import 'package:flutter/material.dart';

import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';

class TopContainer extends StatelessWidget {
  final Widget? child;
  final EdgeInsets? padding;
  final String title;
  final String subtitle;
  final bool isBackButton;
  // ignore: use_key_in_widget_constructors
  const TopContainer(
      {this.child,
      this.padding,
      this.title = 'الجدولة',
      this.subtitle = '           ',
      this.isBackButton = true});

  @override
  Widget build(BuildContext context) {
    double areaScreen = Get.width * Get.height / 1000;

    return Stack(
      children: [
        Container(
          padding:
              padding ?? EdgeInsets.symmetric(horizontal:Get.width/ 10),
          decoration: const BoxDecoration(
              color: Color.fromRGBO(94, 114, 228, 1.0),
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(40.0),
                bottomLeft: Radius.circular(40.0),
              )),
          height: areaScreen / 4,
          child: child ??
              Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 0.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          CircularPercentIndicator(
                            radius: areaScreen / 5.5,
                            lineWidth: 3.0,
                            animation: true,
                            percent: 0.75,
                            // circularStrokeCap: CircularStrokeCap.round,
                            progressColor:
                                const Color.fromRGBO(251, 99, 64, 1.0),
                            backgroundColor:
                                const Color.fromRGBO(94, 114, 228, 1.0),
                            center: CircleAvatar(
                              backgroundColor:
                                  const Color.fromRGBO(82, 95, 127, 1.0),
                              radius: areaScreen / 11.5

                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                title,
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                  fontSize: 22.0,
                                  color: Color.fromRGBO(247, 250, 252, 1.0),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                subtitle,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  ]),
        ),
        if (isBackButton)
          IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(
                Icons.arrow_back_outlined,
                color: Colors.white70,
              ))
      ],
    );
  }
}
