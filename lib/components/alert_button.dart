import 'dart:async';
import 'package:flutter/material.dart';

class BlinkingSOSButton extends StatefulWidget {
  final bool isDanger; // Pass the _isDanger value as a parameter

  const BlinkingSOSButton({required this.isDanger, Key? key}) : super(key: key);

  @override
  _BlinkingSOSButtonState createState() => _BlinkingSOSButtonState();
}

class _BlinkingSOSButtonState extends State<BlinkingSOSButton> {
  bool isBlinking = true; // Initial blinking state

  // Function to toggle blinking state
  void toggleBlinking() {
    setState(() {
      isBlinking = !isBlinking;
    });
  }

  // Function to return the blinking value
  double getOpacity() {
    return isBlinking ? 0.0 : 1.0;
  }

  @override
  void initState() {
    super.initState();

    // Start a periodic timer to toggle blinking when isDanger is true
    Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (mounted && widget.isDanger) {
        toggleBlinking();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('SOS'),
                content: const Text('You are in a danger zone'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            });
      },
      child: Container(
        margin: const EdgeInsets.all(10),
        alignment: Alignment.center,
        width: 37,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: AnimatedOpacity(
          opacity: getOpacity(),
          duration: Duration(milliseconds: 500),
          child: Icon(
            size: 35,
            Icons.admin_panel_settings,
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}