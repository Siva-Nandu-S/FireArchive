import 'package:flutter/material.dart';

class Safety_index extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shield,
                color: Colors.black,
              ),
              SizedBox(width: 8),
              Text(
                'Safety Index',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          centerTitle: true,
          backgroundColor: Colors.white, // Updated color
          elevation: 4, // Increased elevation for a more prominent shadow
          actions: [
            IconButton(
              icon: const Icon(Icons.info),
              color: Colors.black,
              onPressed: () {
                // Add your info button action here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Standard Pollution Index'),
                    duration:
                        Duration(seconds: 3), // Adjust the duration as needed
                  ),
                );
              },
            ),
          ],
        ),
      );
}
