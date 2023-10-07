import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class Service {
  final String name;
  final String phoneNumber;
  final IconData icon;

  Service({
    required this.name,
    required this.phoneNumber,
    required this.icon,
  });
}

final List<Service> services = [
  Service(
    name: 'Police',
    phoneNumber: '123-456-7890',
    icon: Icons.local_police,
  ),
  Service(
    name: 'Ambulance',
    phoneNumber: '987-654-3210',
    icon: Icons.local_hospital,
  ),
  Service(
    name: 'Fire Services',
    phoneNumber: '123456789',
    icon: Icons.local_fire_department,
  ),
  // Add more services as needed
];

class ServicesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      backgroundColor: Colors.grey[200], // Set background color
      body: buildServiceList(),
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
            'Helpline📞',
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
              'Emergency Numbers',
            ),
            duration: Duration(seconds: 3),
          ),
        );
      },
    );
  }

  ListView buildServiceList() {
    return ListView.builder(
      itemCount: services.length,
      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      itemBuilder: (context, index) {
        final service = services[index];
        return buildServiceTab(service);
      },
    );
  }

  Container buildServiceTab(Service service) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Background color for each service
        borderRadius: BorderRadius.circular(15.0), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2), // Add a subtle box shadow
          ),
        ],
      ),
      margin: EdgeInsets.only(bottom: 16.0), // Increased space between tabs
      child: ListTile(
        contentPadding: EdgeInsets.all(16.0),
        tileColor: Colors.transparent, // Transparent background
        leading: Icon(
          service.icon,
          color: Colors.black, // Customize icon color
          size: 32.0, // Increase icon size
        ),
        title: Text(
          service.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
            color: Colors.black, // Text color
          ),
        ),
        subtitle: Text(
          service.phoneNumber,
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: 16.0,
            color: Colors.grey[700], // Text color
          ),
        ),
        onTap: () async {
          final url = 'tel:${service.phoneNumber}';
          if (await canLaunchUrlString(url)) {
            await launchUrlString(url);
          } else {
            throw 'Could not launch $url';
          }
        },
      ),
    );
  }

  void main() {
    runApp(MaterialApp(
      home: ServicesPage(),
    ));
  }
}
