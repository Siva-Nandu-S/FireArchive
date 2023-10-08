import 'package:flutter/material.dart';

class IntensityMeter extends StatelessWidget {
  final int intensity;

  IntensityMeter({required this.intensity});

  @override
  Widget build(BuildContext context) {
    // Define the colors and their corresponding intensities
    final colors = [Colors.green, Colors.yellow, Colors.orange, Colors.red, Color.fromARGB(255, 128, 0, 0)];

    // Calculate the marker position based on the intensity (1 to 5)
    final markerPosition = (intensity - 1).clamp(0, 4);

    // Create a list of color stops for the gradient
    final List<double> stops = [];
    for (int i = 0; i < colors.length; i++) {
      stops.add(i / (colors.length - 1));
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      height: 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10), // Rounded corners
        gradient: LinearGradient(
          colors: colors,
          stops: stops,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            left: 210 * markerPosition / 4, // Calculate the position
            top: 5,
            child: Container(
              width: 10, // Adjust the width of the marker
              height: 10,
              decoration: const BoxDecoration(
                shape: BoxShape.circle, // Make the marker round
                color: Colors.black, // Customize the marker color
              ),
               // Customize the marker color
            ),
          ),
        ],
      ),
    );
  }
}
