import 'package:flutter/material.dart';
import 'package:fyp/HeartDiseaseMonitor/Monitor.dart';
import 'package:fyp/HeartDiseasePrediction/Prediction.dart';
import 'package:fyp/Onboarding/size_config.dart';

import 'package:fyp/utils/side_menu.dart';

class welcome extends StatefulWidget {
  welcome({Key? key}) : super(key: key);

  @override
  State<welcome> createState() => _welcomeState();
}

class _welcomeState extends State<welcome> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    double width = SizeConfig.screenW!;
    double height = SizeConfig.screenH!;
    double blockH = SizeConfig.blockH!;
    double blockV = SizeConfig.blockV!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(26, 93, 160, 1),
        title: Text(
          "CARDIO",
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
      ),
      endDrawer: const SideMenu(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding:
                    EdgeInsets.only(top: 0, bottom: 120, left: 12, right: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Image.asset(
                        'assets/images/MainScreen.png',
                        height: 380,
                        width: 420,
                        fit: BoxFit.fill,
                      ),
                    ),
                    Text(
                      "CARDIO",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "Mulish",
                        fontSize: 35.0,
                        fontWeight: FontWeight.w600,
                        color: Color.fromRGBO(26, 93, 160, 1),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) => Hdp()));
                        },
                        child: Text(
                          "Heart Disease Detector",
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Color.fromRGBO(26, 93, 160, 1),
                          shape: new RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          padding: (width <= 550)
                              ? EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 20)
                              : EdgeInsets.symmetric(
                                  horizontal: width * 0.2, vertical: 25),
                          textStyle: TextStyle(
                            fontFamily: "Mulish",
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        )),
                    SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) => Htest()));
                        },
                        child: Text(
                          "Heart Disease Monitor",
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Color.fromRGBO(26, 93, 160, 1),
                          shape: new RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          padding: (width <= 450)
                              ? EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 20)
                              : EdgeInsets.symmetric(
                                  horizontal: width * 0.2, vertical: 25),
                          textStyle: TextStyle(
                            fontFamily: "Mulish",
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
