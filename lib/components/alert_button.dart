import 'dart:async';
import 'package:flutter/material.dart';

class BlinkingSOSButton extends StatefulWidget {
  final bool isDanger; // Pass the _isDanger value as a parameter

  const BlinkingSOSButton({required this.isDanger, Key? key}) : super(key: key);

  @override
  _BlinkingSOSButtonState createState() => _BlinkingSOSButtonState(isDanger);
}

class _BlinkingSOSButtonState extends State<BlinkingSOSButton> {
  bool isBlinking = true; // Initial blinking state
  bool isDanger = false;

  _BlinkingSOSButtonState(isDanger){
    this.isDanger = isDanger;
  }

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
        isDanger?
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  'Emergency Alert',
                  style: TextStyle(
                    color: Colors.red, // Use a prominent color for the title
                    fontWeight: FontWeight.bold, // Make the title bold
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Danger Zone Alert',
                      style: TextStyle(
                        fontSize: 18.0, // Increase the font size for emphasis
                        fontWeight: FontWeight.bold, // Make the text bold
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'You are currently within a 10KM radius of a severe hotspot. Please take immediate precautions and follow local guidelines.',
                      style: TextStyle(
                        color: Colors
                            .black87, // Use a darker text color for content
                        fontSize: 16.0, // Adjust the font size for readability
                      ),
                    ),
                  ],
                ),
                actions: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors
                          .red, // Use the same prominent color for the button
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'OK',
                      style: TextStyle(
                        color: Colors
                            .white, // Use white text color for better contrast
                      ),
                    ),
                  ),
                ],
              );
            }):null;
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