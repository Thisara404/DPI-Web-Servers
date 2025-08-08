import 'package:flutter/material.dart';
import 'package:transit_lanka/screens/auth/size_config.dart';
import 'package:transit_lanka/shared/constants/colors.dart';
import 'package:transit_lanka/shared/constants/styles.dart';

class RoundedTextField extends StatelessWidget {
  const RoundedTextField({
    Key? key,
    this.initialValue,
    this.hintText,
    this.isPassword = false,
  }) : super(key: key);

  final String? initialValue, hintText;
  final bool isPassword;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hintText ?? "",
          style: AppStyles.bodyText2
              .copyWith(color: AppColors.textLight.withOpacity(0.7)),
        ),
        VerticalSpacing(of: 10),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              width: 2,
              color: AppColors.primary.withOpacity(0.2),
            ),
          ),
          child: TextField(
            style: TextStyle(color: AppColors.textLight),
            controller: TextEditingController(text: initialValue),
            obscureText: isPassword,
            decoration: InputDecoration(
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
