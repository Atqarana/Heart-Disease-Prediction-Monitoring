import 'package:ternav_icons/ternav_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitbitter/fitbitter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import '../theme/colors.dart';
import '../utils/list_View.dart';
import '../utils/list_data.dart';
import '../utils/side_menu.dart';
import '../utils/strings.dart';
import 'package:fyp/fitness_app_theme.dart';
import 'package:fyp/theme/todayclass.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:math' as math;

late ZoomPanBehavior _zoomPanBehavior;

late SfCartesianChart _chart;

class Htest extends StatefulWidget {
  const Htest({Key? key}) : super(key: key);

  @override
  _HtestState createState() => _HtestState();
}

final cartesianChartKey = GlobalKey<_HtestState>();
//////////////////////////////////////////////////////////////////////////////////////

List<_ChartData> chartData = <_ChartData>[];
List<ChartData> chart = <ChartData>[];

class _ChartData {
  _ChartData({this.x, this.y});
  final String? x;
  final int? y;
}

class ChartData {
  ChartData({this.x, this.y});
  final String? x;
  // ignore: prefer_typing_uninitialized_variables
  var y;
}

//////////////////////////////////////////////////////////////////////////////////////

class _HtestState extends State<Htest> {
  late TooltipBehavior _tooltipBehavior;
  var BMR;
  // ignore: non_constant_identifier_names
  String? Date = DateFormat('yyyy-MM-dd').format(DateTime.now());
  DateTime? created = DateTime.now();
  double? StepCount = 0.0;
  double? cal = 0.0;
  var condition;
  int? heartrate = 0;
  //String? sleeplevel;

  void refreshChart() {
    setState(() {});
  }

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(
        enable: true,
        color: Color.fromARGB(255, 59, 66, 69),
        builder: (dynamic data, dynamic point, dynamic series, int pointIndex,
            int seriesIndex) {
          return Container(
              alignment: Alignment.center,
              height: 40,
              width: 50,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 65, 68, 70),
                borderRadius: const BorderRadius.all(Radius.circular(6.0)),
              ),
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
                  child: Row(children: <Widget>[
                    const SizedBox(
                      height: 30,
                      width: 15,
                    ),
                    Text(
                      data.y.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                      textScaleFactor: 1.0,
                    ),
                  ])));
        });
    _zoomPanBehavior = ZoomPanBehavior(
        enablePanning: false,
        enablePinching: false,
        enableDoubleTapZooming: false);
    fitbitdaata();
    getDataFromFireStore().then((results) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {});
      });
    });

    super.initState();
  }

  List<ListData> mealsListData = ListData.tabIconsList;
  Future<void> firebase() async {
    final firestoreInstance = FirebaseFirestore.instance;
    firestoreInstance.collection("HealthData").add({
      "Heart Rate": heartrate,
      "Step Count": StepCount,
      "Calories": cal,
      "CaloriesBMR": BMR,
      "Date": Date,
      "created": created,
      //"SleepLevel": sleeplevel,
    }).then((value) {
      print(value.id);
    })
        // ignore: invalid_return_type_for_catch_error
        .catchError((error) => print("Failed to add user: $error"));
    //
  }

  void _showAlert(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(24),
                ),
              ),
              title: Column(children: [
                Image.asset(
                  'assets/images/heart.png',
                  width: 70,
                  height: 70,
                  fit: BoxFit.contain,
                ),
                Text(
                  "ALERT",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: FitnessAppTheme.fontName,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Color.fromARGB(255, 219, 60, 36),
                  ),
                ),
              ]),
              content: Text(
                "Your Heart Rate is Irregular.. Contact your Doctor!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: FitnessAppTheme.fontName,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color.fromARGB(255, 72, 64, 63),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text("OK",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: FitnessAppTheme.fontName,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Color.fromRGBO(26, 93, 160, 1),
                      )),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ));
  }

  Future<void> getDataFromFireStore() async {
    var snapShotsValue = await FirebaseFirestore.instance
        .collection("HealthData")
        .orderBy("created")
        .get();
    List<_ChartData> list = snapShotsValue.docs
        .map((e) => _ChartData(
              x: e.data()['Date'],
              y: e.data()['Heart Rate'],
            ))
        .toList();
    List<ChartData> lists = snapShotsValue.docs
        .map((e) => ChartData(
              x: e.data()['Date'],
              y: e.data()['Step Count'],
            ))
        .toList();
    setState(() {
      chartData = list;
      chart = lists;
    });
  }

  Future<void> firebaseRead() async {
    // firestoreInstance
    final firestoreInstance = FirebaseFirestore.instance;
    firestoreInstance
        .collection("HealthData")
        .orderBy("created")
        .get()
        .then((value) {
      value.docs.forEach((result) {
        print(result.data());
      });
    });
  }

  Future<void> firebaseupdate() async {
    final firestoreInstance = FirebaseFirestore.instance;

    final post = await firestoreInstance
        .collection("HealthData")
        .where('Date', isEqualTo: Date)
        .get()
        .then((QuerySnapshot snapshot) {
      //Here we get the document reference and return to the post variable.
      return snapshot.docs[0].reference;
    });
    var batch = firestoreInstance.batch();
    condition = true;
    //Updates the field value, using post as document reference
    batch.set(post, {
      "Heart Rate": heartrate,
      "Step Count": StepCount,
      "Calories": cal,
      "CaloriesBMR": BMR,
      "Date": Date,
      "created": created,
      // "SleepLevel": sleeplevel,
    });

    batch.commit();
  }

  Future<void> fitbitdaata() async {
    await FitbitConnector.storage.read(key: 'fitbitAccessToken');
    await FitbitConnector.storage.read(key: 'fitbitRefreshToken');
    bool valid = await FitbitConnector.isTokenValid();

    // Authorize the app
    String? userId = await FitbitConnector.authorize(
        context: context,
        clientID: Strings.fitbitClientID,
        clientSecret: Strings.fitbitClientSecret,
        redirectUri: Strings.fitbitRedirectUri,
        callbackUrlScheme: Strings.fitbitCallbackScheme);
    print(userId);

    //Calories
    FitbitActivityTimeseriesDataManager fitbitActivityTimeseriesDataManager =
        FitbitActivityTimeseriesDataManager(
      clientID: Strings.fitbitClientID,
      clientSecret: Strings.fitbitClientSecret,
      type: 'calories',
    );
    final Calories = await fitbitActivityTimeseriesDataManager
        .fetch(FitbitActivityTimeseriesAPIURL.dayWithResource(
      date: DateTime.now(),
      userID: userId,
      resource: fitbitActivityTimeseriesDataManager.type,
    )) as List<FitbitActivityTimeseriesData>;

    //calories BMR

    FitbitActivityTimeseriesDataManager fitbitActivityTimeseriesDataManagere =
        FitbitActivityTimeseriesDataManager(
      clientID: Strings.fitbitClientID,
      clientSecret: Strings.fitbitClientSecret,
      type: 'minutesVeryActive',
    );

    //Fetch caloriesBMR data
    final calBMR = await fitbitActivityTimeseriesDataManagere
        .fetch(FitbitActivityTimeseriesAPIURL.dayWithResource(
      date: DateTime.now(),
      userID: userId,
      resource: fitbitActivityTimeseriesDataManagere.type,
    )) as List<FitbitActivityTimeseriesData>;

    //Instantiate a proper data manager
    FitbitActivityTimeseriesDataManager fitbitActivityTimeseriesDataManagerr =
        FitbitActivityTimeseriesDataManager(
      clientID: Strings.fitbitClientID,
      clientSecret: Strings.fitbitClientSecret,
      type: 'steps',
    );
    //Fetch step data
    final stepsData = await fitbitActivityTimeseriesDataManagerr
        .fetch(FitbitActivityTimeseriesAPIURL.dayWithResource(
      date: DateTime.now(),
      userID: userId,
      resource: fitbitActivityTimeseriesDataManagerr.type,
    )) as List<FitbitActivityTimeseriesData>;

    //define heart rate function
    FitbitHeartDataManager fitbitHeartDataManager = FitbitHeartDataManager(
      clientID: Strings.fitbitClientID,
      clientSecret: Strings.fitbitClientSecret,
    );
    FitbitHeartAPIURL fitbitHeartApiUrl = FitbitHeartAPIURL.dayWithUserID(
      date: DateTime.now(),
      userID: userId,
    );
    //Fetch heart data
    final HeartData = await fitbitHeartDataManager.fetch(fitbitHeartApiUrl)
        as List<FitbitHeartData>;

    //Sleep data
    FitbitSleepDataManager fitbitSleepDataManager = FitbitSleepDataManager(
      clientID: Strings.fitbitClientID,
      clientSecret: Strings.fitbitClientSecret,
    );
    FitbitSleepAPIURL fitbitSleepAPIURL = FitbitSleepAPIURL.withUserIDAndDay(
      userID: userId,
      date: DateTime.now(),
    );
    final sleepData = await fitbitSleepDataManager.fetch(fitbitSleepAPIURL)
        as List<FitbitSleepData>;
    // Use them as you want
    final snackBar = SnackBar(content: Text('Synced...'));

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    setState(() {
      // updating the state
      StepCount = stepsData[0].value;
      heartrate = HeartData[0].restingHeartRate;
      cal = Calories[0].value;
      BMR = calBMR[0].value;
      //String? sleeplevel = sleepData[0].level;
    });

    print("heart rate:$heartrate");
    firebaseupdate();
    if (condition != true) {
      firebase();
    } else {
      print("updated");
    }

    firebaseRead();

    // Firebase
    if (heartrate! >= 70) {
      _showAlert(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> color = <Color>[];
    color.add(Color.fromARGB(255, 148, 210, 237));
    color.add(Color.fromARGB(255, 124, 167, 236));
    color.add(Color.fromARGB(255, 2, 24, 71));

    final List<double> stops = <double>[];
    stops.add(0.0);
    stops.add(0.5);
    stops.add(1.0);

    final LinearGradient gradientColors =
        LinearGradient(colors: color, stops: stops);
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text("Health Monitor"),
        backgroundColor: Color.fromRGBO(26, 93, 160, 1),
      ),
      endDrawer: const SideMenu(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            const SizedBox(height: 10),
            SizedBox(
              height: 12,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 28, right: 26),
                  child: Text(
                    "HEALTH STATUS",
                    style: TextStyle(
                      fontFamily: FitnessAppTheme.fontName,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      letterSpacing: 0.5,
                      color: FitnessAppTheme.lightText,
                    ),
                  ),
                ),
              ],
            ),
////////////////////////////////////////////////////////////////////////////////////

            Padding(
              padding: const EdgeInsets.only(
                  left: 24, right: 24, top: 16, bottom: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: FitnessAppTheme.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      bottomLeft: Radius.circular(8.0),
                      bottomRight: Radius.circular(8.0),
                      topRight: Radius.circular(68.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: FitnessAppTheme.grey.withOpacity(0.2),
                        offset: Offset(1.1, 1.1),
                        blurRadius: 10.0),
                  ],
                ),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 16, left: 16, right: 16),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 8, right: 8, top: 4),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Container(
                                        height: 48,
                                        width: 2,
                                        decoration: BoxDecoration(
                                          color: HexColor('#87A0E5')
                                              .withOpacity(0.5),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4.0)),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 4, bottom: 2),
                                              child: Text(
                                                'Heart Rate',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily:
                                                      FitnessAppTheme.fontName,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16,
                                                  letterSpacing: -0.1,
                                                  color: FitnessAppTheme.grey
                                                      .withOpacity(0.5),
                                                ),
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: <Widget>[
                                                SizedBox(
                                                  width: 28,
                                                  height: 28,
                                                  child: Image.asset(
                                                      "assets/images/heart.png"),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 4, bottom: 3),
                                                  child: Text(
                                                    '${(heartrate)}',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          FitnessAppTheme
                                                              .fontName,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 16,
                                                      color: FitnessAppTheme
                                                          .darkerText,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 4, bottom: 3),
                                                  child: Text(
                                                    'BPM',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          FitnessAppTheme
                                                              .fontName,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 12,
                                                      letterSpacing: -0.2,
                                                      color: FitnessAppTheme
                                                          .grey
                                                          .withOpacity(0.5),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Container(
                                        height: 48,
                                        width: 2,
                                        decoration: BoxDecoration(
                                          color: HexColor('#F56E98')
                                              .withOpacity(0.5),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4.0)),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 4, bottom: 2),
                                              child: Text(
                                                'Step Count',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily:
                                                      FitnessAppTheme.fontName,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16,
                                                  letterSpacing: -0.1,
                                                  color: FitnessAppTheme.grey
                                                      .withOpacity(0.5),
                                                ),
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: <Widget>[
                                                SizedBox(
                                                  width: 28,
                                                  height: 28,
                                                  child: Image.asset(
                                                      "assets/images/footstep.png"),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 4, bottom: 3),
                                                  child: Text(
                                                    '${(StepCount!.toInt())}',
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      fontFamily:
                                                          FitnessAppTheme
                                                              .fontName,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 16,
                                                      color: FitnessAppTheme
                                                          .darkerText,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8, bottom: 3),
                                                  child: Text(
                                                    'Steps',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          FitnessAppTheme
                                                              .fontName,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 12,
                                                      letterSpacing: -0.2,
                                                      color: FitnessAppTheme
                                                          .grey
                                                          .withOpacity(0.5),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Center(
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: FitnessAppTheme.white,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(100.0),
                                        ),
                                        border: new Border.all(
                                            width: 4,
                                            color: FitnessAppTheme
                                                .nearlyDarkBlue
                                                .withOpacity(0.2)),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            'Health',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily:
                                                  FitnessAppTheme.fontName,
                                              fontWeight: FontWeight.normal,
                                              fontSize: 20,
                                              letterSpacing: 0.0,
                                              color: FitnessAppTheme
                                                  .nearlyDarkBlue,
                                            ),
                                          ),
                                          Text(
                                            'Status',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily:
                                                  FitnessAppTheme.fontName,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              letterSpacing: 0.0,
                                              color: FitnessAppTheme.grey
                                                  .withOpacity(0.5),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: CustomPaint(
                                      painter: CurvePainter(colors: [
                                        FitnessAppTheme.nearlyDarkBlue,
                                        HexColor("#8A98E8"),
                                        HexColor("#8A98E8")
                                      ], angle: 140 + (360 - 140) * (1.0)),
                                      child: SizedBox(
                                        width: 108,
                                        height: 108,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 24, right: 24, top: 8, bottom: 8),
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: FitnessAppTheme.background,
                          borderRadius: BorderRadius.all(Radius.circular(4.0)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 24, right: 24, top: 8, bottom: 16),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Calories',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: FitnessAppTheme.fontName,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    letterSpacing: -0.2,
                                    color: FitnessAppTheme.darkText,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Container(
                                    height: 4,
                                    width: 70,
                                    decoration: BoxDecoration(
                                      color:
                                          HexColor('#87A0E5').withOpacity(0.2),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(4.0)),
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          width: ((70 / 1.2)),
                                          height: 4,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(colors: [
                                              HexColor('#87A0E5'),
                                              HexColor('#87A0E5')
                                                  .withOpacity(0.5),
                                            ]),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(4.0)),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    '${(cal)}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: FitnessAppTheme.fontName,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color:
                                          FitnessAppTheme.grey.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Activity',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: FitnessAppTheme.fontName,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        letterSpacing: -0.2,
                                        color: FitnessAppTheme.darkText,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Container(
                                        height: 4,
                                        width: 70,
                                        decoration: BoxDecoration(
                                          color: HexColor('#F56E98')
                                              .withOpacity(0.2),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4.0)),
                                        ),
                                        child: Row(
                                          children: <Widget>[
                                            Container(
                                              width: ((70 / 2)),
                                              height: 4,
                                              decoration: BoxDecoration(
                                                gradient:
                                                    LinearGradient(colors: [
                                                  HexColor('#F56E98')
                                                      .withOpacity(0.1),
                                                  HexColor('#F56E98'),
                                                ]),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(4.0)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(
                                        '${(BMR)}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: FitnessAppTheme.fontName,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                          color: FitnessAppTheme.grey
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Sleep',
                                      style: TextStyle(
                                        fontFamily: FitnessAppTheme.fontName,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        letterSpacing: -0.2,
                                        color: FitnessAppTheme.darkText,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 0, top: 4),
                                      child: Container(
                                        height: 4,
                                        width: 70,
                                        decoration: BoxDecoration(
                                          color: HexColor('#F1B440')
                                              .withOpacity(0.2),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4.0)),
                                        ),
                                        child: Row(
                                          children: <Widget>[
                                            Container(
                                              width: ((70 / 2.5)),
                                              height: 4,
                                              decoration: BoxDecoration(
                                                gradient:
                                                    LinearGradient(colors: [
                                                  HexColor('#F1B440')
                                                      .withOpacity(0.1),
                                                  HexColor('#F1B440'),
                                                ]),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(4.0)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(
                                        'wake',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: FitnessAppTheme.fontName,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                          color: FitnessAppTheme.grey
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
//////////////////////////////////////////////////////////////////////////////////////
            Padding(
                padding: const EdgeInsets.only(
                    left: 24, right: 24, top: 16, bottom: 18),
                child: Container(
                    height: 220,
                    decoration: BoxDecoration(
                      color: FitnessAppTheme.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8.0),
                          bottomLeft: Radius.circular(8.0),
                          bottomRight: Radius.circular(8.0),
                          topRight: Radius.circular(68.0)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: FitnessAppTheme.grey.withOpacity(0.2),
                            offset: const Offset(1.1, 1.1),
                            blurRadius: 10.0),
                      ],
                    ),
                    child: SfCartesianChart(
                        tooltipBehavior: _tooltipBehavior,
                        title: ChartTitle(text: 'Heart Rate'),
                        zoomPanBehavior: _zoomPanBehavior,
                        onZooming: (ZoomPanArgs args) {
                          cartesianChartKey.currentState?.refreshChart();
                        },
                        enableAxisAnimation: true,
                        primaryXAxis: CategoryAxis(
                          isVisible: false,
                          majorGridLines: MajorGridLines(width: 0),
                          //Hide the axis line of x-axis
                          axisLine: AxisLine(width: 0),
                        ),
                        primaryYAxis: NumericAxis(
                          name: 'primaryYAxis',
                          isVisible: false,
                          majorGridLines: MajorGridLines(width: 0),
                          //Hide the axis line of x-axis
                          axisLine: AxisLine(width: 0),
                        ),
                        plotAreaBorderWidth: 0,
                        legend: Legend(isVisible: false),
                        series: <ChartSeries<_ChartData, String>>[
                          SplineAreaSeries<_ChartData, String>(
                              name: "Heart Rate",
                              dataSource: chartData,
                              xValueMapper: (_ChartData data, _) => data.x,
                              yValueMapper: (_ChartData data, _) => data.y,
                              borderWidth: 4,
                              gradient: gradientColors)
                        ]))),
            /////////////////////////////////////////////////////////////////////////////////
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 28, right: 26),
                  child: Text(
                    "RECOMMENDATIONS",
                    style: TextStyle(
                      fontFamily: FitnessAppTheme.fontName,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      letterSpacing: 0.6,
                      color: FitnessAppTheme.lightText,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              height: 216,
              width: double.infinity,
              child: ListView.builder(
                padding: const EdgeInsets.only(
                    top: 0, bottom: 0, right: 16, left: 16),
                itemCount: mealsListData.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  return MealsView(
                    mealsListData: mealsListData[index],
                  );
                },
              ),
            ),
//////////////////////////////////////////////////////////////////////////////////
            Padding(
                padding: const EdgeInsets.only(
                    left: 24, right: 24, top: 16, bottom: 18),
                child: Container(
                    decoration: BoxDecoration(
                      color: FitnessAppTheme.white,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8.0),
                          bottomLeft: Radius.circular(8.0),
                          bottomRight: Radius.circular(8.0),
                          topRight: Radius.circular(68.0)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: FitnessAppTheme.grey.withOpacity(0.2),
                            offset: const Offset(1.1, 1.1),
                            blurRadius: 10.0),
                      ],
                    ),
                    child: SfCartesianChart(
                        title: ChartTitle(text: 'Step Count'),
                        zoomPanBehavior: _zoomPanBehavior,
                        onZooming: (ZoomPanArgs args) {
                          cartesianChartKey.currentState?.refreshChart();
                        },
                        primaryXAxis: CategoryAxis(
                          isVisible: false,
                          majorGridLines: MajorGridLines(width: 0),
                          //Hide the axis line of x-axis
                          axisLine: AxisLine(width: 0),
                        ),
                        primaryYAxis: NumericAxis(
                          name: 'primaryYAxis',
                          isVisible: true,
                          majorGridLines: const MajorGridLines(width: 0),
                          //Hide the axis line of x-axis
                          axisLine: const AxisLine(width: 0),
                        ),
                        plotAreaBorderWidth: 0,
                        legend: Legend(isVisible: false),
                        series: <ChartSeries>[
                          BarSeries<ChartData, String>(
                              name: "Step Count",
                              dataSource: chart,
                              xValueMapper: (ChartData data, _) => data.x,
                              yValueMapper: (ChartData data, _) => data.y,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              borderWidth: 2,
                              gradient: gradientColors)
                        ]))),

///////////////////////////////////////////////////////////////////////////////////////////////
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 28, right: 26),
                  child: Text(
                    "PRECAUTIONS",
                    style: TextStyle(
                      fontFamily: FitnessAppTheme.fontName,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      letterSpacing: 0.6,
                      color: FitnessAppTheme.lightText,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 24, right: 18),
                  child: Text(
                    "Seek Medical Help, if you have any of the Symptoms listed below",
                    style: TextStyle(
                        fontFamily: FitnessAppTheme.fontName,
                        fontSize: 11,
                        color: Colors.redAccent),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Column(
              children: List.generate(latestActivityJson.length, (index) {
                return Padding(
                  padding:
                      const EdgeInsets.only(left: 18, right: 18, bottom: 20),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: FitnessAppTheme.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8.0),
                          bottomLeft: Radius.circular(8.0),
                          bottomRight: Radius.circular(8.0),
                          topRight: Radius.circular(68.0)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: FitnessAppTheme.grey.withOpacity(0.2),
                            offset: Offset(1.1, 1.1),
                            blurRadius: 10.0),
                      ],
                      /*   BoxShadow(
                              color: black.withOpacity(0.01),
                              spreadRadius: 20,
                              blurRadius: 10,
                              offset: Offset(0, 1)),
                        ],
                        borderRadius: BorderRadius.circular(12)*/
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 55,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: AssetImage(
                                            latestActivityJson[index]['img']))),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Container(
                                height: 55,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      latestActivityJson[index]['title'],
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      latestActivityJson[index]['time_ago'],
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: black.withOpacity(0.5)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),

////////////////////////////////////////////////////////////////////////////////////////////////
          ],
        ),
      ),
    ));
  } //build

} //HomePage

////////////////////////////////////////////////////////////////////////////////

//Holds the data source of chart
class CurvePainter extends CustomPainter {
  final double? angle;
  final List<Color>? colors;

  CurvePainter({this.colors, this.angle = 140});

  @override
  void paint(Canvas canvas, Size size) {
    List<Color> colorsList = [];
    if (colors != null) {
      colorsList = colors ?? [];
    } else {
      colorsList.addAll([Colors.white, Colors.white]);
    }

    final shdowPaint = new Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;
    final shdowPaintCenter = new Offset(size.width / 2, size.height / 2);
    final shdowPaintRadius =
        math.min(size.width / 2, size.height / 2) - (14 / 2);
    canvas.drawArc(
        new Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle!)),
        false,
        shdowPaint);

    shdowPaint.color = Colors.grey.withOpacity(0.3);
    shdowPaint.strokeWidth = 16;
    canvas.drawArc(
        new Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle!)),
        false,
        shdowPaint);

    shdowPaint.color = Colors.grey.withOpacity(0.2);
    shdowPaint.strokeWidth = 20;
    canvas.drawArc(
        new Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle!)),
        false,
        shdowPaint);

    shdowPaint.color = Colors.grey.withOpacity(0.1);
    shdowPaint.strokeWidth = 22;
    canvas.drawArc(
        new Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle!)),
        false,
        shdowPaint);

    final rect = new Rect.fromLTWH(0.0, 0.0, size.width, size.width);
    final gradient = new SweepGradient(
      startAngle: degreeToRadians(268),
      endAngle: degreeToRadians(270.0 + 360),
      tileMode: TileMode.repeated,
      colors: colorsList,
    );
    final paint = new Paint()
      ..shader = gradient.createShader(rect)
      ..strokeCap = StrokeCap.round // StrokeCap.round is not recommended.
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;
    final center = new Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - (14 / 2);

    canvas.drawArc(
        new Rect.fromCircle(center: center, radius: radius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle!)),
        false,
        paint);

    final gradient1 = new SweepGradient(
      tileMode: TileMode.repeated,
      colors: [Colors.white, Colors.white],
    );

    var cPaint = new Paint();
    cPaint..shader = gradient1.createShader(rect);
    cPaint..color = Colors.white;
    cPaint..strokeWidth = 14 / 2;
    canvas.save();

    final centerToCircle = size.width / 2;
    canvas.save();

    canvas.translate(centerToCircle, centerToCircle);
    canvas.rotate(degreeToRadians(angle! + 2));

    canvas.save();
    canvas.translate(0.0, -centerToCircle + 14 / 2);
    canvas.drawCircle(new Offset(0, 0), 14 / 5, cPaint);

    canvas.restore();
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  double degreeToRadians(double degree) {
    var redian = (math.pi / 180) * degree;
    return redian;
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
  }) : super(key: key);
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      horizontalTitleGap: 0,
      leading: Icon(
        icon,
        color: Colors.grey,
        size: 18,
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }
}

class MealsView extends StatelessWidget {
  const MealsView({Key? key, this.mealsListData}) : super(key: key);

  final ListData? mealsListData;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Padding(
          padding:
              const EdgeInsets.only(top: 32, left: 8, right: 8, bottom: 16),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: HexColor(mealsListData!.endColor).withOpacity(0.6),
                    offset: const Offset(1.1, 4.0),
                    blurRadius: 8.0),
              ],
              gradient: LinearGradient(
                colors: <HexColor>[
                  HexColor(mealsListData!.startColor),
                  HexColor(mealsListData!.endColor),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(8.0),
                bottomLeft: Radius.circular(8.0),
                topLeft: Radius.circular(8.0),
                topRight: Radius.circular(54.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 54, left: 16, right: 16, bottom: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    mealsListData!.titleTxt,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: FitnessAppTheme.fontName,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.2,
                      color: FitnessAppTheme.white,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            mealsListData!.meals!.join('\n'),
                            style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                              letterSpacing: 0.2,
                              color: FitnessAppTheme.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        mealsListData!.kacl,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: FitnessAppTheme.fontName,
                          fontWeight: FontWeight.w500,
                          fontSize: 24,
                          letterSpacing: 0.2,
                          color: FitnessAppTheme.white,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 3),
                        child: Text(
                          mealsListData!.unit,
                          style: TextStyle(
                            fontFamily: FitnessAppTheme.fontName,
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                            letterSpacing: 0.2,
                            color: FitnessAppTheme.white,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: FitnessAppTheme.nearlyWhite.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 8,
          child: SizedBox(
            width: 80,
            height: 85,
            child: Image.asset(
              mealsListData!.imagePath,
              fit: BoxFit.fill,
              height: 100,
              width: 100,
            ),
          ),
        )
      ],
    );
  }
}

const List latestActivityJson = [
  {
    "img": "assets/images/report.png",
    "title": "Chest Pain",
    "time_ago":
        "A feeling of pressure, heaviness and \ntightness or squeezing across chest"
  },
  {
    "img": "assets/images/report.png",
    "title": "Shortness of Breath.",
    "time_ago":
        "Trouble in breathing, can occur with \nor without chest discomfort."
  },
  {
    "img": "assets/images/report.png",
    "title": "Feeling lightheaded or Dizzy.",
    "time_ago":
        "You may feel little light-headedness \nor faintness and turning pale. "
  },
  {
    "img": "assets/images/report.png",
    "title": "Discomfort in a Body",
    "time_ago": "Pain  in the arms, left shoulder, elbows, \njaw, or back."
  },
  {
    "img": "assets/images/report.png",
    "title": "Other Signs",
    "time_ago":
        "Nausea ,cold sweats, coughing or \nwheezing and irregular heartbeats"
  },
];
