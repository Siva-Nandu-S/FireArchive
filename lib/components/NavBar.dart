import 'package:flutter/material.dart'; 
import 'package:fire_archive/components/helpline.dart'; // This imports the helpline.dart file.
import 'package:fire_archive/components/safety_index.dart'; // This imports the safety_index.dart file.
import 'package:fire_archive/components/safety_std.dart';

class NavBar extends StatelessWidget {
  final padding = const EdgeInsets.symmetric(horizontal: 20); // Sets the padding for the navigation bar.

  @override
  Widget build(BuildContext context) {
  return Drawer(
    child: Material(
      color: Colors.white, // Background color of the drawer
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent
                ],
              ),
              image: DecorationImage(
                image: AssetImage("assets/icons/drawerheader.jpg"),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                "Dashboard",
                style: TextStyle(
                  fontSize: 35,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          buildMenuItem(
            text: 'Safety Index',
            icon: Icons.add_chart_outlined,
            onClicked: () => selectedItem(context, 0),
          ),
          const SizedBox(height: 20),
          buildMenuItem(
            text: 'Safety Standards',
            icon: Icons.security_rounded,
            onClicked: () => selectedItem(context, 2),
          ),
          const SizedBox(height: 20),
          const Divider(
            color: Colors.grey,
            indent: 20,
            endIndent: 20,
          ),
          const SizedBox(height: 20),
          buildMenuItem(
            text: 'Helpline Numbers',
            icon: Icons.phone,
            onClicked: () => selectedItem(context, 1),
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}

Widget buildMenuItem({
  required String text,
  required IconData icon,
  VoidCallback? onClicked,
}) {
  return ListTile(
    leading: Icon(
      icon,
      color: Colors.black,
      size: 30, // Adjust the icon size
    ),
    title: Text(
      text,
      style: TextStyle(
        color: Colors.black,
        fontSize: 20, // Adjust the text size
      ),
    ),
    onTap: onClicked,
  );
}

void selectedItem(BuildContext context, int index) {
  Navigator.of(context).pop();

  switch (index) {
    case 0:
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AirQualityTable(),
      ));
      break;
    case 1:
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ServicesPage(),
      ));
      break;
    case 2:
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => safety_std(),
      ));
      break;
  }
}

}
