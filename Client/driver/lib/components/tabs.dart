import 'package:flutter/material.dart';
import 'package:transit_lanka/screens/auth/size_config.dart';
import 'package:transit_lanka/shared/constants/colors.dart';

class Tabs extends StatelessWidget {
  const Tabs({
    Key? key,
    required this.press,
  }) : super(key: key);

  final ValueChanged<int> press;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: SizeConfig.screenWidth * 0.8, // 80%
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DefaultTabController(
        length: 2,
        child: TabBar(
          indicator: BoxDecoration(
            color: AppColors.tertiary,
            borderRadius: BorderRadius.circular(12),
          ),
          labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          labelColor: AppColors.textLight,
          unselectedLabelColor: AppColors.textLight.withOpacity(0.7),
          onTap: press,
          tabs: [Tab(text: "Passenger Login"), Tab(text: "Driver Login")],
        ),
      ),
    );
  }
}
