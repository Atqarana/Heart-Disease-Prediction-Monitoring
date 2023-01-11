import 'package:flutter/material.dart';

class OnboardingContents {
  final String title;
  final String image;
  final String desc;

  OnboardingContents(
      {required this.title, required this.image, required this.desc});
}

List<OnboardingContents> contents = [
  OnboardingContents(
    title: "Welcome To Healthy Heart",
    image: "assets/images/onboarding1.png",
    desc:
        "All type of health Care solutions in one place to take care of your Health!!",
  ),
  OnboardingContents(
    title: "Stay healthy and monitor your health",
    image: "assets/images/onboarding3.png",
    desc:
        "Now you can easily check if you are having a Heart Disease and keep track of your Health Status",
  ),
  OnboardingContents(
    title: "Get notified when your health declines",
    image: "assets/images/onboard.png",
    desc: "Take control of your health and stay updated about your health",
  ),
];
