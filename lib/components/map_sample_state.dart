import 'dart:async';
import 'dart:convert';
import 'package:fire_archive/components/NavBar.dart';
import 'package:fire_archive/components/intensityMeter.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'package:fire_archive/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import "dart:math" show asin, cos, pi, pow, sin, sqrt;
import 'package:geocoding/geocoding.dart';
import 'package:fire_archive/components/alert_button.dart';

class AirQualityBar extends StatelessWidget {
  final int aqi; // Air Quality Index value
  final List<Color> gradientColors;

  AirQualityBar({super.key, required this.aqi}) : gradientColors = _getGradientColors(aqi);

  static List<Color> _getGradientColors(int aqi) {
    // Define color ranges based on AQI levels
    if (aqi >= 0 && aqi <= 1) {
      // Green: 0 to 50
      return [Colors.green, Colors.green];
    } else if (aqi <= 2) {
      // Yellow: 51 to 100
      return [Colors.yellow, Colors.yellow];
    } else if (aqi <= 3) {
      // Orange: 101 to 150
      return [Colors.orange, Colors.orange];
    } else if (aqi <= 4) {
      // Red: 151 to 200
      return [Colors.red, Colors.red];
    }else {
      // Maroon: 301 and higher
      return [const Color.fromARGB(255, 128, 0, 0), const Color.fromARGB(255, 128, 0, 0),];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20.0, // Adjust the height of the bar as needed
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }
}




class MapSampleState extends State<MapSample> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Completer<GoogleMapController> _controller =
      Completer(); // Controller for the Google Map.
  final TextEditingController _locationController =
      TextEditingController(); // Controller for the location text field.
  List<List<dynamic>>? locations; // List of hotspot locations.

  // ignore: prefer_typing_uninitialized_variables
  var _userPosition_lat, _userPosition_lng;
  bool _isDanger = false;

  // Constants
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(20.42796133580664, 80.885749655962),
    zoom: 4.5,
  );

  List<Marker> markers = <Marker>[
    const Marker(
      markerId: MarkerId('1'),
      // position: LatLng(20.42796133580664, 75.885749655962),
      infoWindow: InfoWindow(
          // title: 'Some Position',
          ),
    ),
  ];

  late String searchedLocation;

  // Searched location for the Google Map.

  List<List<dynamic>>? hotspots;

  @override
  void initState() {
    super.initState();

    var client = http.Client();
    client
        .get(Uri.parse(
            'https://firms.modaps.eosdis.nasa.gov/api/country/csv/3d27399c8e1faa664e38874ea2330ac5/VIIRS_SNPP_NRT/IND/1/2023-10-07'))
        .then((response) async {
      String data = response.body;
      List<List<dynamic>> res = const CsvToListConverter().convert(data);
      hotspots = res;

      setMarkers(hotspots!);
    });
    
  }

  List<Marker> spots = [];
  List<Marker> redSpots = [];

  void setMarkers(locations) async {

    var data = locations[0].join(',').toString();
    var dataList = data.split('\n');

    for (int i = 1; i < dataList.length; i++) {
      var newData = dataList[i].split(',');
      double latitude = double.parse(newData[1]);
      double longitude = double.parse(newData[2]);
      double brightness = double.parse(newData[3]);

      if (brightness > 355) {
        spots += <Marker>[
          Marker(
            markerId: MarkerId(i.toString()),
            position: LatLng(latitude, longitude),
            infoWindow: const InfoWindow(
              title: '',
            ),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            onTap: () {
              _showMyDialog(latitude, longitude);
            },
          ),
        ];
        redSpots += <Marker>[
          Marker(
            markerId: MarkerId(i.toString()),
            position: LatLng(latitude, longitude),
            infoWindow: const InfoWindow(
              title: '',
            ),
          ),
        ];
      } else if (brightness > 335) {
        spots += <Marker>[
          Marker(
            markerId: MarkerId(i.toString()),
            position: LatLng(latitude, longitude),
            infoWindow: const InfoWindow(
              title: '',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueOrange),
            onTap: () {
              _showMyDialog(latitude, longitude);
            },
          ),
        ];
      } else {
        spots += <Marker>[
          Marker(
            markerId: MarkerId(i.toString()),
            position: LatLng(latitude, longitude),
            infoWindow: const InfoWindow(
              title: '',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueYellow),
            onTap: () {
              _showMyDialog(latitude, longitude);
            },
          ),
        ];
      }
    }
    setState(() {
      markers.addAll(spots);
    });
  }

  Future<void> _showMyDialog(latitude, longitude) async {
    var client = http.Client();
    // ignore: prefer_typing_uninitialized_variables
    var data;
    await client
        .get(Uri.parse(
            'http://api.openweathermap.org/data/2.5/air_pollution?lat=$latitude&lon=$longitude&appid=7aec4f8d030b3228e06daddc0646ce4a'))
        .then((response) async {
      data = json.decode(response.body);
    });
    int aqi = data['list'][0]['main']['aqi'];
    data = data['list'][0]['components'];
    // ignore: use_build_context_synchronously


 Widget buildDetailRow(String title, String value){  // Build the details row.
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,  
        children: <Widget>[
          Text(title),
          Text(value),
        ],
      );
    }
    // ignore: use_build_context_synchronously
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
    return AlertDialog(
      title: const Text('Details', style: TextStyle(fontWeight: FontWeight.bold)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      content: Container(
        height: 310,
        width: 100,
        child: Column(
        children: <Widget>[
          const SizedBox(height: 10),
          const Text('Air Quality Index', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          IntensityMeter(intensity: aqi,),
          const SizedBox(height: 15), 
          buildDetailRow('Air Quality', '$aqi'),
          buildDetailRow('CO', '${data['co']}'),
          buildDetailRow('NO', '${data['no']}'),
          buildDetailRow('NO2', '${data['no2']}'),
          buildDetailRow('O3', '${data['o3']}'),
          buildDetailRow('SO2', '${data['so2']}'),
          buildDetailRow('PM2.5', '${data['pm2_5']}'),
          buildDetailRow('PM10', '${data['pm10']}'),
          buildDetailRow('NH3', '${data['nh3']}'),
        ],
      ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Done', style: TextStyle(color: Colors.blue)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  },
);
  }

  double degreesToRadians(double degrees) {
    return degrees * (pi / 180.0);
  }

  void _setSOS() {
    _userPosition_lat = degreesToRadians(15.6393);
    _userPosition_lng = degreesToRadians(78.2842);
    for (int i = 0; i < redSpots.length; i++) {
      double lat = degreesToRadians(redSpots[i].position.latitude);
      double lng = degreesToRadians(redSpots[i].position.longitude);

      double dLng = lng - _userPosition_lng;
      double dLat = lat - _userPosition_lat;

      double a = pow(sin(dLat / 2), 2) +
          cos(_userPosition_lat) * cos(lat) * pow(sin(dLng / 2), 2);

      double c = 2 * asin(sqrt(a));
      double r = 6371;

      double distance = c * r;

      if (distance < 10) {
        _isDanger = true;
      }
    }
  }


  @override
  void dispose() {
    // Dispose of resources here.
    _locationController.dispose();
    super.dispose();
  }

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) async {
      await Geolocator.requestPermission();
    });
    return await Geolocator.getCurrentPosition();
  }

 void searchLocation(String searchedLocation) async {
  try {
    List<Location> locations = await locationFromAddress(searchedLocation);

    if (locations.isNotEmpty) {
      Location firstLocation = locations.first;
      double latitude = firstLocation.latitude;
      double longitude = firstLocation.longitude;


      markers.add(
        Marker(
          markerId: const MarkerId("searchedLocation"),
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(
            title: searchedLocation,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
          onTap: () {
            _showMyDialog(latitude, longitude);
          },
        ),
      );

      // Move the camera to the searched location
      CameraPosition cameraPosition = CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 8,
      );

      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      setState(() {});
    } else {
      // Handle the case where no location data is available
      print('No location data available for: $searchedLocation');
    }
  } catch (e) {
    print('Error searching location: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: NavBar(),
      appBar: myAppBar(),
      backgroundColor: Colors.white,
      body: buildBody(),
      floatingActionButton: buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

 AppBar myAppBar() {
  return AppBar(
    title: const Text(
      'FireArchive🧑‍🚒',
      style: TextStyle(
        color: Colors.black,
        fontSize: 25,
        fontWeight: FontWeight.bold,
      ),
    ),
    backgroundColor: Colors.white,
    elevation: 0.0,
    centerTitle: true,
    leading: GestureDetector(
      onTap: () {
        // Handle menu icon tap
        _scaffoldKey.currentState?.openDrawer();
      },
      // Handle menu
      child: Container(
        margin: const EdgeInsets.all(10),
        alignment: Alignment.center,
        child: SvgPicture.asset(
          'assets/icons/menu-1.svg',
          height: 35,
          width: 35,
        ),
      ),
    ),
    actions: [
      BlinkingSOSButton(isDanger: _isDanger,), // Use the BlinkingSOSButton widget here
    ],
  );
}


  Widget buildBody() {
    return Column(
      children: [
        buildSearchRow(),
        Expanded(
          child: GoogleMap(
            mapType: MapType.normal,
            markers: Set<Marker>.of(markers),
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
        ),
      ],
    );
  }

  Widget buildSearchRow() {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 1,
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: 'Search Location',
                hintStyle: const TextStyle(
                  color: Color(0xffDDDADA),
                  fontSize: 15,
                ),
                border: InputBorder.none,
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(8),
                  child: SvgPicture.asset(
                    'assets/icons/loc-1.svg',
                    colorFilter: const ColorFilter.mode(
                      Color.fromARGB(255, 109, 107, 106),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              onChanged: (value) {
                searchedLocation = value;
                searchLocation(searchedLocation);
              },
            ),
          ),
        ),
        IconButton(
          onPressed: () async {
            searchLocation(searchedLocation);
          },
          icon: const Icon(
            Icons.search,
            color: Color(0xffDDDADA),
          ),
        ),
      ],
    ),
  );
}


  Widget buildFloatingActionButton() {
  return Padding(
    padding: const EdgeInsets.only(bottom: 50.0),
    child: Tooltip(
      message: 'Current Location', // Tooltip text
      child: FloatingActionButton(
        onPressed: () async {
          getUserCurrentLocation().then((value) async {
            markers.add(
              Marker(
                markerId: const MarkerId("0"),
                position: LatLng(value.latitude, value.longitude),
                infoWindow: const InfoWindow(
                  title: 'My Current Location',
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueAzure),
                onTap: () {
                  _showMyDialog(value.latitude, value.longitude);
                },
              ),
            );

            CameraPosition cameraPosition = CameraPosition(
              target: LatLng(value.latitude, value.longitude),
              zoom: 8,
            );

            _userPosition_lat = value.latitude;
            _userPosition_lng = value.longitude;

            final GoogleMapController controller = await _controller.future;
            controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
            setState(() {});

            _setSOS();
          });
        },
        child: const Icon(Icons.location_on), // Icon for current location
      ),
    ),
  );
}
}