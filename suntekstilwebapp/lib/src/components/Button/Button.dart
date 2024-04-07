  import 'package:flutter/material.dart';
  import 'package:suntekstilwebapp/src/constants/theme.dart';
  import 'package:suntekstilwebapp/src/constants/tokens.dart';

  class CustomButton extends StatelessWidget {
    final String buttonText;
    final void Function()? onPressed;
    final Color buttonColor;
    final Color textColor;
    final double fontSize;

    CustomButton({
      required this.buttonText,
      required this.onPressed,
      this.buttonColor = Themes.blueColor, 
      this.textColor = Themes.whiteColor, 
      this.fontSize = 14.0,
    });

    @override
    Widget build(BuildContext context) {
      return ElevatedButton(
        child: Text(
          buttonText,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
          ),
        ),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor
        ),
      );
    }
  }
