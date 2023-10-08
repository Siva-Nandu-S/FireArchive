import 'dart:async';
import 'dart:convert';
import 'package:fire_archive/components/NavBar.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'package:fire_archive/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class AirQualityBar extends StatelessWidget {
  final int aqi; // Air Quality Index value
  final List<Color> gradientColors;

  AirQualityBar({required this.aqi}) : gradientColors = _getGradientColors(aqi);

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
      return [const Color.fromARGB(255, 128, 0, 0), Color.fromARGB(255, 128, 0, 0),];
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

  // Constants
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(20.42796133580664, 80.885749655962),
    zoom: 4.5,
  );

  List<Marker> markers = <Marker>[
    const Marker(
      markerId: MarkerId('1'),
      position: LatLng(20.42796133580664, 75.885749655962),
      infoWindow: InfoWindow(
        title: 'Some Position',
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
            'https://firms.modaps.eosdis.nasa.gov/api/country/csv/3d27399c8e1faa664e38874ea2330ac5/VIIRS_NOAA20_NRT/IND/1/2023-10-07'))
        .then((response) async {
      String data = response.body;
      List<List<dynamic>> res = const CsvToListConverter().convert(data);
      print("From Main Function");
      hotspots = res;

      setMarkers(hotspots!);
    });

    // _setMarker(LatLng(37.42796133580664, -122.085749655962));
  }

  List<Marker> spots = [];

  void setMarkers(locations) async {
    print("From setMarkers Method");

    var data = locations[0].join(',').toString();
    var dataList = data.split('\n');

    for (int i = 1; i < dataList.length; i++) {
      var newData = dataList[i].split(',');
      double latitude = double.parse(newData[1]);
      double longitude = double.parse(newData[2]);
      String place = '$latitude,$longitude';

      spots += <Marker>[
        Marker(
          markerId: MarkerId(i.toString()),
          position: LatLng(latitude, longitude),
          infoWindow: const InfoWindow(
            title: '',
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          onTap: () {
            _showMyDialog(latitude, longitude);
          },
        ),
      ];
    }
    print('spots: $spots');
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
            'http://api.openweathermap.org/data/2.5/air_pollution?lat=${latitude}&lon=${longitude}&appid=7aec4f8d030b3228e06daddc0646ce4a'))
        .then((response) async {
      data = json.decode(response.body);
    });
    var aqi = data['list'][0]['main']['aqi'];
    data = data['list'][0]['components'];
    print(data);
    // ignore: use_build_context_synchronously
    Widget _buildDetailRow(String label, String value) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label),
      Text(value),
    ],
  );
}
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
    return AlertDialog(
      title: Text('Details', style: TextStyle(fontWeight: FontWeight.bold)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      content: Container(
        height: 300,
        width: 100,
        child: Column(
        children: <Widget>[
          SizedBox(height: 10),
          Text('Air Quality Index', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          AirQualityBar(aqi: aqi),
          SizedBox(height: 15),
          _buildDetailRow('AQI', '$aqi'),
          _buildDetailRow('CO', '${data['co']}'),
          _buildDetailRow('NO', '${data['no']}'),
          _buildDetailRow('NO2', '${data['no2']}'),
          _buildDetailRow('O3', '${data['o3']}'),
          _buildDetailRow('SO2', '${data['so2']}'),
          _buildDetailRow('PM2.5', '${data['pm2_5']}'),
          _buildDetailRow('PM10', '${data['pm10']}'),
          _buildDetailRow('NH3', '${data['nh3']}'),
        ],
      ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Done', style: TextStyle(color: Colors.blue)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  },
);

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
      print("ERROR: $error");
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
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueViolet),
          ),
        );

        // Move the camera to the searched location
        CameraPosition cameraPosition = CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 12,
        );

        final GoogleMapController controller = await _controller.future;
        controller
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
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
        'FireArchive🧯',
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
        GestureDetector(
          onTap: () {
            // Handle admin icon tap
          },
          child: Container(
            margin: const EdgeInsets.all(10),
            alignment: Alignment.center,
            width: 37,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              color: Colors.black,
            ),
          ),
        ),
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
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(15),
                  hintText: 'Search Location',
                  hintStyle: const TextStyle(
                    color: Color(0xffDDDADA),
                    fontSize: 15,
                  ),
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  searchedLocation = value;
                  searchLocation(searchedLocation);
                },
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () async {
            // Add your search functionality here.
          },
          icon: const Icon(Icons.search),
        ),
      ],
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
                  markerId: const MarkerId("2"),
                  position: LatLng(value.latitude, value.longitude),
                  infoWindow: const InfoWindow(
                    title: 'My Current Location',
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueAzure),
                ),
              );

              CameraPosition cameraPosition = CameraPosition(
                target: LatLng(value.latitude, value.longitude),
                zoom: 14,
              );

              final GoogleMapController controller = await _controller.future;
              controller.animateCamera(
                  CameraUpdate.newCameraPosition(cameraPosition));
              setState(() {});
            });
          },
          child: const Icon(Icons.location_on), // Icon for current location
        ),
      ),
    );
  }
}
