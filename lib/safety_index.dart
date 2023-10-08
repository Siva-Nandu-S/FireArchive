import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AirQualityTable(),
    );
  }
}

class AirQualityInfo {
  final String color;
  final String level;
  final String range;
  final String description;

  AirQualityInfo({
    required this.color,
    required this.level,
    required this.range,
    required this.description,
  });
}

class AirQualityTable extends StatelessWidget {
  final List<AirQualityInfo> data = [
    AirQualityInfo(
        color: 'rgb(0, 228, 0)',
        level: 'Good',
        range: '0 to 50',
        description:
            'Air quality is satisfactory, and air pollution poses little or no risk.'),
    AirQualityInfo(
        color: 'rgb(255, 255, 0)',
        level: 'Moderate',
        range: '51 to 100',
        description:
            'Air quality is acceptable. However, there may be a risk for some people, particularly those who are unusually sensitive to air pollution.'),
    AirQualityInfo(
        color: 'rgb(255, 126, 0)',
        level: 'Unhealthy for Sensitive Groups',
        range: '101 to 150',
        description:
            'Members of sensitive groups may experience health effects. The general public is less likely to be affected.'),
    AirQualityInfo(
        color: 'rgb(255, 0, 0)',
        level: 'Unhealthy',
        range: '151 to 200',
        description:
            'Some members of the general public may experience health effects; members of sensitive groups may experience more serious health effects.'),
    AirQualityInfo(
        color: 'rgb(143, 63, 151)',
        level: 'Very Unhealthy',
        range: '201 to 300',
        description:
            'Health alert: The risk of health effects is increased for everyone.'),
    AirQualityInfo(
        color: 'rgb(126, 0, 35)',
        level: 'Hazardous',
        range: '301 and higher',
        description:
            'Health warning of emergency conditions: everyone is more likely to be affected.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      backgroundColor: Colors.grey[200],
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          final info = data[index];
          return Card(
            elevation: 4.0,
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              leading: Container(
                width: 30,
                height: 30,
                //color: _parseColor(info.color),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _parseColor(info.color),
                ),
              ),
              title: Text(
                info.level,
                style: TextStyle(fontSize: 20),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Range: ${info.range}',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(info.description),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 8),
          Text(
            'Safety Index',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 25, color: Colors.black),
          ),
        ],
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 4,
      actions: [
        buildInfoIconButton(context),
      ],
    );
  }

  IconButton buildInfoIconButton(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.info),
      color: Colors.black,
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Standard Air Quality Index',
            ),
            duration: Duration(seconds: 3),
          ),
        );
      },
    );
  }

  Color _parseColor(String color) {
    if (color.startsWith('rgb')) {
      final rgb = color
          .substring(4, color.length - 1)
          .split(',')
          .map((e) => int.parse(e.trim()))
          .toList();
      return Color.fromRGBO(rgb[0], rgb[1], rgb[2], 1);
    } else {
      return Colors.transparent;
    }
  }
}
