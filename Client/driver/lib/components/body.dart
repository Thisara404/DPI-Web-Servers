import 'dart:async';

import 'package:flutter/material.dart';
import 'package:transit_lanka/screens/auth/size_config.dart';
import 'package:transit_lanka/shared/constants/colors.dart';
import 'package:transit_lanka/shared/constants/styles.dart';

import 'land.dart';
import 'rounded_text_field.dart';
import 'sun.dart';
import 'tabs.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  bool isFullSun = false;
  bool isDayMood = true;
  Duration _duration = Duration(seconds: 1);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        isFullSun = true;
      });
    });
  }

  void changeMood(int activeTabNum) {
    if (activeTabNum == 0) {
      setState(() {
        isDayMood = true;
      });
      Future.delayed(Duration(milliseconds: 300), () {
        setState(() {
          isFullSun = true;
        });
      });
    } else {
      setState(() {
        isFullSun = false;
      });
      Future.delayed(Duration(milliseconds: 300), () {
        setState(() {
          isDayMood = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Color> lightBgColors = [
      AppColors.primaryDark,
      AppColors.primary,
      AppColors.secondaryLight,
      if (isFullSun) AppColors.tertiaryLight,
    ];
    var darkBgColors = [
      Color(0xFF0D1441),
      AppColors.primaryDark,
      AppColors.secondary,
    ];
    return AnimatedContainer(
      duration: _duration,
      curve: Curves.easeInOut,
      width: double.infinity,
      height: SizeConfig.screenHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDayMood ? lightBgColors : darkBgColors,
        ),
      ),
      child: Stack(
        children: [
          Sun(duration: _duration, isFullSun: isFullSun),
          Land(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VerticalSpacing(of: 50),
                  Tabs(
                    press: (value) {
                      changeMood(value);
                    },
                  ),
                  VerticalSpacing(),
                  Text(
                    "Transit Lanka",
                    style:
                        AppStyles.heading1.copyWith(color: AppColors.textLight),
                  ),
                  VerticalSpacing(of: 10),
                  Text(
                    "Enter your information below",
                    style: AppStyles.bodyText2
                        .copyWith(color: AppColors.textLight),
                  ),
                  VerticalSpacing(of: 50),
                  RoundedTextField(
                    initialValue: "user@example.com",
                    hintText: "Email",
                  ),
                  VerticalSpacing(),
                  RoundedTextField(
                    initialValue: "XXXXXXX",
                    hintText: "Password",
                    isPassword: true,
                  ),
                  VerticalSpacing(of: 30),
                  ElevatedButton(
                    style: AppStyles.primaryButton,
                    onPressed: () {},
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text("LOGIN"),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
