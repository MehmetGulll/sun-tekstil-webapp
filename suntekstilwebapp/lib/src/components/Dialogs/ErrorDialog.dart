import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:suntekstilwebapp/src/components/Button/Button.dart';
import 'package:suntekstilwebapp/src/constants/theme.dart';
import 'package:suntekstilwebapp/src/constants/tokens.dart';

class ErrorDialog extends StatefulWidget {
  final String errorMessage;
  final IconData errorIcon;

  ErrorDialog({required this.errorMessage, required this.errorIcon});

  @override
  _ErrorDialogState createState() => _ErrorDialogState();
}

class _ErrorDialogState extends State<ErrorDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: FractionallySizedBox(
        heightFactor: 0.4,
        widthFactor: 0.4,
        child: Container(
          decoration: BoxDecoration(
            color: Themes.secondaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _controller,
                child: Icon(
                  widget.errorIcon,
                  color: Themes.whiteColor,
                  size: 60.0,
                ),
              ),
              Text(
                widget.errorMessage,
                style: TextStyle(
                    color: Themes.whiteColor, fontSize: Tokens.fontSize[7]),
              ),
              SizedBox(
                height: 80,
              ),
              CustomButton(
                buttonText: 'Tamam',
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
