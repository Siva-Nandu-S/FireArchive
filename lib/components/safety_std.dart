import 'package:flutter/material.dart';

class safety_std extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.grey[200],
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
                'Safety Standard',
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
                        'Standard procedures to reduce fire-related accidents'),
                    duration:
                        Duration(seconds: 3), // Adjust the duration as needed
                  ),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SectionCard(
                  title: "🚨 Smoke Alarms and Detection Systems",
                  content:
                      "Install smoke alarms in key areas of the building, such as bedrooms and hallways. "
                      "Regularly test and maintain smoke alarms to ensure they are in working condition. "
                      "Consider interconnected smoke alarms so that when one detects smoke, all alarms in the building sound simultaneously.",
                ),
                SectionCard(
                  title: "🔥 Fire Extinguishers",
                  content:
                      "Place fire extinguishers in easily accessible locations throughout the building. "
                      "Regularly inspect and maintain fire extinguishers to ensure they are in working order. "
                      "Provide appropriate training to occupants on how to use fire extinguishers.",
                ),
                SectionCard(
                  title: "🚨 Emergency Evacuation Plans",
                  content:
                      "Develop and post clear evacuation plans that include exit routes and assembly points. "
                      "Conduct regular fire drills to ensure that occupants are familiar with evacuation procedures. "
                      "Assign responsibilities to specific individuals to assist with evacuation, such as floor wardens or fire marshals.",
                ),
                SectionCard(
                  title: "💡 Emergency Lighting",
                  content:
                      "Install emergency lighting to provide illumination in the event of a power failure. "
                      "Ensure that exit signs are well-lit and clearly visible.",
                ),
                SectionCard(
                  title: "💦 Fire Suppression Systems",
                  content:
                      "Install automatic fire suppression systems, such as sprinklers, where appropriate. "
                      "Regularly inspect and maintain these systems to ensure they are operational.",
                ),
                SectionCard(
                  title: "⚡ Electrical Safety",
                  content:
                      "Regularly inspect and maintain electrical systems to prevent electrical fires. "
                      "Avoid overloading electrical outlets and use appropriate extension cords.",
                ),
              ],
            ),
          ),
        ),
      );
}

class SectionCard extends StatelessWidget {
  final String title;
  final String content;

  SectionCard({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Presentable App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: safety_std(),
    );
  }
}
