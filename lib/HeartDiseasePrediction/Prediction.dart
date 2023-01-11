import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:fitbitter/fitbitter.dart';
import 'package:fyp/utils/side_menu.dart';
import '../utils/strings.dart';
import '../welcome.dart';

class Hdp extends StatefulWidget {
  const Hdp({Key? key}) : super(key: key);
  @override
  _HdpState createState() => _HdpState();
}

class _HdpState extends State<Hdp> {
  final TextEditingController age = TextEditingController();
  final TextEditingController maxHR = TextEditingController();
  int gender = 0;
  int chestPainType = 0;
  int exerciseAngina = 0;
  int sugar = 0;
  var heartRate = null;

  @override
  void initState() {
    setState(() {
      HeartRatedaata();
    });
    super.initState();
  }

  Future<void> HeartRatedaata() async {
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
    setState(() {
      // updating the state
      heartRate = HeartData[0].restingHeartRate;
    });

    print("heart rate:$heartRate");
  }

  void onSubmitData() async {
    try {
      // final Dio dio = Dio();
      // final base_url = dio.options.headers['content-Type'] = 'application/json';
      var options = BaseOptions(
        connectTimeout: 60 * 1000,
        receiveTimeout: 60 * 1000,
      );
      final Dio dio = Dio(options);
      Map<String, dynamic> mydata = {
        "age": int.parse(age.text),
        "gender": gender,
        "MaxHR": int.parse(maxHR.text),
        "ChestPainType": chestPainType,
        "ExerciseAngina": exerciseAngina,
        "FastingBS": sugar,
      };
      print(mydata);
      await dio
          .post("http://172.24.54.49:8000/pred",
              data: json.encode(mydata),
              options: Options(
                  method: 'POST',
                  responseType: ResponseType.json,
                  headers: {
                    'Accept': 'application/json',
                  }))
          .then((value) {
        print("response from post , ${value.data}");
        if (value.data == 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'You have risk of heart disease! Contact your Doctor for checkup.'),
              duration: const Duration(milliseconds: 5000),
              width: 320.0, // Width of the SnackBar.
              padding: const EdgeInsets.symmetric(
                horizontal: 30.0, // Inner padding for SnackBar content.
                vertical: 12.0,
              ),
              backgroundColor: Colors.red.shade600,

              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Congratulations! You have no risk of Heart Disease yet.'),
              duration: const Duration(milliseconds: 5000),
              width: 320.0, // Width of the SnackBar.
              padding: const EdgeInsets.symmetric(
                horizontal: 30.0, // Inner padding for SnackBar content.
                vertical: 12.0,
              ),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          );
        }
      });
    } on DioError catch (e) {
      print(e.message);
      if (e.response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${e.response?.data["detail"]}'),
            duration: const Duration(milliseconds: 2000),
            width: 320.0, // Width of the SnackBar.
            padding: const EdgeInsets.symmetric(
              horizontal: 30.0, // Inner padding for SnackBar content.
              vertical: 12.0,
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
            title: const Text(
              "Heart Disease Detection",
            ),
            backgroundColor: const Color.fromRGBO(26, 93, 160, 1),
            leading: IconButton(
              icon: new Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => welcome(),
            )),
        endDrawer: SideMenu(),
        body: SingleChildScrollView(
          child: SafeArea(
              child: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                  // ignore: avoid_unnecessary_containers
                  child: Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Heart Disease Prediction",
                                style: TextStyle(
                                    color: Color.fromRGBO(26, 93, 160, 1),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600)),
                            DropdownButton(
                              isExpanded: true,
                              value: gender,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              elevation: 16,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontFamily: "Poppins"),
                              underline: Container(
                                height: 1.5,
                                color: Color.fromRGBO(26, 93, 160, 1),
                              ),
                              onChanged: (int? newValue) {
                                setState(() {
                                  gender = newValue!;
                                });
                              },
                              hint: const Text("Select"),
                              items: const [
                                DropdownMenuItem(
                                    enabled: false,
                                    value: 0,
                                    child: Text("Gender ")),
                                DropdownMenuItem(
                                  value: 1,
                                  child: Text("Male"),
                                ),
                                DropdownMenuItem(
                                    value: 2, child: Text("Female")),
                              ],
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: age,
                              textCapitalization: TextCapitalization.sentences,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              style: TextStyle(fontSize: 13),
                              decoration: const InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color.fromRGBO(26, 93, 160, 1),
                                          width: 1.5)),
                                  contentPadding:
                                      EdgeInsets.fromLTRB(0, 15, 15, 3),
                                  border: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color.fromRGBO(26, 93, 160, 1),
                                          width: 2)),
                                  hintText: 'Enter your Age',
                                  labelText: "Age"),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextField(
                              controller: maxHR,
                              textCapitalization: TextCapitalization.sentences,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              style: TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color.fromRGBO(26, 93, 160, 1),
                                        width: 1.5)),
                                contentPadding:
                                    EdgeInsets.fromLTRB(0, 15, 15, 3),
                                border: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color.fromRGBO(26, 93, 160, 1),
                                        width: 2)),
                                hintText: 'Resting Heart Rate',
                                labelText: "Heart Rate",
                                suffixIcon: IconButton(
                                    icon: Icon(Icons.watch),
                                    onPressed: () {
                                      if (heartRate == null) {
                                        hintText:
                                        'Resting Heart Rate';
                                      } else {
                                        maxHR.text = heartRate.toString();
                                      }
                                    }),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            DropdownButton<int>(
                              isExpanded: true,
                              value: chestPainType,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              elevation: 16,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontFamily: "Poppins"),
                              underline: Container(
                                height: 1.5,
                                color: Color.fromRGBO(26, 93, 160, 1),
                              ),
                              onChanged: (int? newValue) {
                                setState(() {
                                  chestPainType = newValue!;
                                });
                              },
                              hint: Text("Select Chest pain type"),
                              items: [
                                DropdownMenuItem(
                                    enabled: false,
                                    child: Text("Select Chest pain type"),
                                    value: 0),
                                DropdownMenuItem(
                                  child: Text("Typical Angina"),
                                  value: 1,
                                ),
                                DropdownMenuItem(
                                    child: Text("ATypical Angina"), value: 2),
                                DropdownMenuItem(
                                    child: Text("Non-Anginal Pain"), value: 3),
                                DropdownMenuItem(
                                    child: Text("Asymptomatic"), value: 4),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            DropdownButton<int>(
                              isExpanded: true,
                              value: sugar,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              elevation: 16,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontFamily: "Poppins"),
                              underline: Container(
                                height: 1.5,
                                color: Color.fromRGBO(26, 93, 160, 1),
                              ),
                              onChanged: (int? newValue) {
                                setState(() {
                                  sugar = newValue!;
                                });
                              },
                              hint: Text("Select"),
                              items: [
                                DropdownMenuItem(
                                  enabled: false,
                                  child: Text("Diabetes Patient"),
                                  value: 0,
                                ),
                                DropdownMenuItem(
                                  child: Text("Yes"),
                                  value: 1,
                                ),
                                DropdownMenuItem(child: Text("No"), value: 2),
                              ],
                            ),
                            SizedBox(height: 20),
                            DropdownButton<int>(
                              isExpanded: true,
                              value: exerciseAngina,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              elevation: 16,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontFamily: "Poppins"),
                              underline: Container(
                                height: 1.5,
                                color: Color.fromRGBO(26, 93, 160, 1),
                              ),
                              onChanged: (int? newValue) {
                                setState(() {
                                  exerciseAngina = newValue!;
                                });
                              },
                              hint: Text("Select"),
                              items: const [
                                DropdownMenuItem(
                                    enabled: false,
                                    value: 0,
                                    child:
                                        Text("Select Exercise Induced Angina")),
                                DropdownMenuItem(child: Text("Yes"), value: 1),
                                DropdownMenuItem(child: Text("No"), value: 2),
                              ],
                            ),
                            const SizedBox(height: 30),
                            Container(
                              height: 50,
                              width: 200,
                              margin: EdgeInsets.symmetric(horizontal: 50),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: const LinearGradient(colors: [
                                  Color.fromRGBO(29, 35, 102, 1),
                                  Color.fromARGB(255, 57, 131, 192)
                                ]),
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  onSubmitData();
                                },
                                child: Center(
                                  child: Text(
                                    "PREDICT".toUpperCase(),
                                    style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ])))),
        ));
  }
}
