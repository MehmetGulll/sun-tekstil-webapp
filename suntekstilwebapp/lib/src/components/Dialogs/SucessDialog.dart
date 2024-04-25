import 'package:flutter/material.dart';
import 'package:suntekstilwebapp/src/components/Button/Button.dart';
import 'package:suntekstilwebapp/src/constants/theme.dart';
import 'package:suntekstilwebapp/src/constants/tokens.dart';

class SuccessDialog extends StatefulWidget {
  final String successMessage;
   final IconData successIcon;

  SuccessDialog({required this.successMessage, required this.successIcon});

  @override
  _SuccessDialogState createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<SuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds:500),
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
            color: Themes.greenColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _controller,
                child: Icon(
                 widget.successIcon,
                  color: Themes.whiteColor,
                  size: 60.0,
                ),
              ),
              Text(
                widget.successMessage,
                style: TextStyle(
                    color: Themes.whiteColor, fontSize: Tokens.fontSize[7]),
              ),
              SizedBox(
                height: 80,
              ),
              CustomButton(
                buttonText: 'Tamam',
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
