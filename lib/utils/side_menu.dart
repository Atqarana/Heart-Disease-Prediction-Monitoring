import 'package:fitbitter/fitbitter.dart';
import 'package:flutter/material.dart';
import 'package:fyp/HeartDiseasePrediction/Prediction.dart';
import 'package:fyp/welcome.dart';
import 'package:ternav_icons/ternav_icons.dart';
import 'package:fyp/utils/constant.dart';
import 'package:fyp/HeartDiseaseMonitor/Monitor.dart';

import 'strings.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width / 1.5,
      child: ListView(
        shrinkWrap: true,
        children: [
          SizedBox(
            height: 150,
            child: DrawerHeader(
                child: Image.asset(
              "assets/images/name.png",
              fit: BoxFit.fill,
            )),
          ),
          DrawerListTile(
            icon: TernavIcons.lightOutline.home_2,
            title: "Home",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => welcome()),
              );
            },
          ),
          DrawerListTile(
            icon: TernavIcons.lightOutline.statistics,
            title: "Health Monitor",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Htest()),
              );
            },
          ),
          DrawerListTile(
            icon: TernavIcons.lightOutline.heart,
            title: "Disease Detection",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Hdp()),
              );
            },
          ),
          DrawerListTile(
            icon: TernavIcons.lightOutline.logout,
            title: "Fitbit Signout",
            onTap: () async {
              await FitbitConnector.unauthorize(
                clientID: Strings.fitbitClientID,
                clientSecret: Strings.fitbitClientSecret,
              );
            },
          )
        ],
      ),
    );
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
        color: Color.fromRGBO(26, 93, 160, 1),
        size: 20,
      ),
      title: Text(
        title,
        style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Color.fromRGBO(26, 93, 160, 1)),
      ),
    );
  }
}
