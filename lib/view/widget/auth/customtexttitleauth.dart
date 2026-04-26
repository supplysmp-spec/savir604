// ignore_for_file: prefer_const_constructors

import 'package:tks/core/constant/color.dart';
import 'package:flutter/material.dart';

class CustomTextTitleAuth extends StatelessWidget {
  final String text;
  const CustomTextTitleAuth({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
          fontWeight: FontWeight.bold,
          color: ColorApp.black,
          fontSize: 22,
          fontFamily: "myfontstart"),
    );
  }
}
