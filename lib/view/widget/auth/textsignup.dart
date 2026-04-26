import 'package:tks/core/constant/color.dart';
import 'package:flutter/material.dart';

class CustomTextSignUpOrSignIn extends StatelessWidget {
  final String textone;
  final String texttwo;
  final void Function() onTap;

  const CustomTextSignUpOrSignIn(
      {super.key,
      required this.textone,
      required this.texttwo,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(textone),
        InkWell(
          onTap: onTap, // استخدم onTap هنا
          child: Text(texttwo,
              style: const TextStyle(
                  color: ColorApp.praimaryColor, fontWeight: FontWeight.bold)),
        )
      ],
    );
  }
}
