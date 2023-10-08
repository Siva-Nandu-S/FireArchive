import 'dart:async'; // For using the Timer class.
import 'dart:convert'; // For decoding JSON data.
import 'package:fire_archive/components/NavBar.dart'; // For the navigation bar.
import 'package:http/http.dart' as http; // For making HTTP requests.
import 'package:csv/csv.dart'; // For parsing CSV data. 
import 'package:fire_archive/main.dart';  // For the main function.
import 'package:flutter/material.dart'; // For the Material design.
import 'package:flutter_svg/svg.dart';  // For the SVG icons.
import 'package:geolocator/geolocator.dart';  // For getting the user's current location.
import 'package:google_maps_flutter/google_maps_flutter.dart';  // For the Google Maps.
import "dart:math" show asin, cos, pi, pow, sin, sqrt;  // For the mathematical functions.
import 'package:geocoding/geocoding.dart';  // For getting the location from the address.


class AirQualityBar extends StatelessWidget { // For the air quality bar widget on the map.
  final int aqi; // Air Quality Index value for the location.
  final List<Color> gradientColors; // Gradient colors for the bar.

  AirQualityBar({required this.aqi}) : gradientColors = _getGradientColors(aqi); // Constructor for the AirQualityBar class.

  static List<Color> _getGradientColors(int aqi) { 
    // Define color ranges based on AQI levels
    if (aqi >= 0 && aqi <= 1) { // If the AQI is between 0 and 50.
      // Green: 0 to 50
      return [Colors.green, Colors.green]; // Return the green color.
    } else if (aqi <= 2) { // If the AQI is between 51 and 100.
      // Yellow: 51 to 100
      return [Colors.yellow, Colors.yellow];
    } else if (aqi <= 3) { // If the AQI is between 101 and 150.
      // Orange: 101 to 150
      return [Colors.orange, Colors.orange];
    } else if (aqi <= 4) { // If the AQI is between 151 and 200.
      // Red: 151 to 200 
      return [Colors.red, Colors.red];
    }else { // If the AQI is greater than 200.
      // Maroon: 301 and higher
      return [const Color.fromARGB(255, 128, 0, 0), Color.fromARGB(255, 128, 0, 0),];
    }
  }

  @override
  Widget build(BuildContext context) { // Build the air quality bar.
    return Container(
      height: 20.0, // Adjust the height of the bar as needed
      decoration: BoxDecoration( // Decorate the bar.
        gradient: LinearGradient( // Use a linear gradient for the bar.
          colors: gradientColors, // Use the gradient colors defined above.
          begin: Alignment.centerLeft,  // Align the gradient to the left.
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }
}



class MapSampleState extends State<MapSample> { // For the state of the MapSample class.
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Key for the scaffold.
  final Completer<GoogleMapController> _controller =
      Completer(); // Controller for the Google Map.
  final TextEditingController _locationController =
      TextEditingController(); // Controller for the location text field.
  List<List<dynamic>>? locations; // List of hotspot locations.

  var _userPosition_lat, _userPosition_lng; // User's current position.
  bool _isDanger = false; // Whether the user is in a danger zone.

  // Constants
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(20.42796133580664, 80.885749655962), // Default location for the Google Map.
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

  late String searchedLocation; // Searched location for the Google Map.

  // Searched location for the Google Map.

  List<List<dynamic>>? hotspots;  // List of hotspot locations.

  @override
  void initState() {
    super.initState();

    var client = http.Client(); // HTTP client for making requests.
    client
        .get(Uri.parse(
            'https://firms.modaps.eosdis.nasa.gov/api/country/csv/3d27399c8e1faa664e38874ea2330ac5/VIIRS_SNPP_NRT/IND/1'))
        .then((response) async {  // Get the hotspot data from the NASA API.
      String data = response.body;
      List<List<dynamic>> res = const CsvToListConverter().convert(data); // Convert the CSV data to a list.
      hotspots = res; // Set the hotspots list to the converted CSV data.

      setMarkers(hotspots!);  // Set the markers on the Google Map.
    });
  }

  List<Marker> spots = [];  // List of markers for the Google Map.
  List<Marker> redSpots = []; // List of red markers for the Google Map.

  void setMarkers(locations) async {
    var data = locations[0].join(',').toString(); // Get the data from the CSV file.
    var dataList = data.split('\n');  // Split the data by new line.

    for (int i = 1; i < dataList.length; i++) {
      var newData = dataList[i].split(','); // Split the data by comma.
      double latitude = double.parse(newData[1]); // Get the latitude.
      double longitude = double.parse(newData[2]);  // Get the longitude.
      double brightness = double.parse(newData[3]); // Get the brightness.
      String place = '$latitude,$longitude';

      if (brightness > 355) { // If the brightness is greater than 355.
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
              _showMyDialog(latitude, longitude); // Show the dialog for the marker.
            },
          ),
        ];
        redSpots += <Marker>[ // Add the marker to the red spots list.
          Marker( 
            markerId: MarkerId(i.toString()),
            position: LatLng(latitude, longitude),
            infoWindow: const InfoWindow(
              title: '',
            ),
          ),
        ];
      } else if (brightness > 335) {  // If the brightness is greater than 335.
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
      markers.addAll(spots);  // Add the markers to the Google Map.
    });
  }

  Future<void> _showMyDialog(latitude, longitude) async { // Show the dialog for the marker.
    var client = http.Client(); // HTTP client for making requests.
    // ignore: prefer_typing_uninitialized_variables
    var data;
    await client
        .get(Uri.parse(
            'http://api.openweathermap.org/data/2.5/air_pollution?lat=$latitude&lon=$longitude&appid=7aec4f8d030b3228e06daddc0646ce4a'))
        .then((response) async {  // Get the air quality data from the OpenWeather API.
      data = json.decode(response.body);  // Decode the JSON data.
    }); 
    var aqi = data['list'][0]['main']['aqi']; // Get the air quality index.
    data = data['list'][0]['components']; // Get the air quality data.
    // ignore: use_build_context_synchronously

    Widget _buildDetailRow(String title, String value) {  // Build the details row.
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,  
        children: <Widget>[
          Text(title),
          Text(value),
        ],
      );
    }
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
        height: 300,
        width: 100,
        child: Column(
        children: <Widget>[
          const SizedBox(height: 10),
          const Text('Air Quality Index', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          AirQualityBar(aqi: aqi),
          const SizedBox(height: 15), 
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

  double degreesToRadians(double degrees) { // Convert degrees to radians.
    return degrees * (pi / 180.0);  // Return the radians.
  }

  void _setSOS() {
    _userPosition_lat = degreesToRadians(15.6393300); // User's current latitude. (default)
    _userPosition_lng = degreesToRadians(78.2842300); // User's current longitude (default).
    for (int i = 0; i < redSpots.length; i++) {
      double lat = degreesToRadians(redSpots[i].position.latitude); // Get the latitude of the hotspot.
      double lng = degreesToRadians(redSpots[i].position.longitude);  // Get the longitude of the hotspot.

      double dLng = lng - _userPosition_lng;  // Get the difference in longitude.

      double dLat = lat - _userPosition_lat;  // Get the difference in latitude.

      double a = pow(sin(dLat / 2), 2) +
          cos(_userPosition_lat) * cos(lat) * pow(sin(dLng / 2), 2);  // Get the distance.

      double c = 2 * asin(sqrt(a)); // Get the distance.

      double r = 6371;  // Radius of the Earth.

      double distance = c * r;  // Get the distance.

      if (distance < 10) {
        _isDanger = true; // Set the danger flag to true if the distance is less than 10KM.
      }
    }
  }

  @override
  void dispose() {  
    // Dispose of resources here.
    _locationController.dispose();  // Dispose of the location controller.
    super.dispose();
  }

  Future<Position> getUserCurrentLocation() async { // Get the user's current location.
    await Geolocator.requestPermission()  // Request permission to get the user's location.
        .then((value) {})
        .onError((error, stackTrace) async {
      await Geolocator.requestPermission(); 
    });
    return await Geolocator.getCurrentPosition(); // Return the user's current position.
  }   

  void searchLocation(String searchedLocation) async {  // Search for a location.
    try {
      List<Location> locations = await locationFromAddress(searchedLocation); // Get the location from the address.

      if (locations.isNotEmpty) {
        Location firstLocation = locations.first; // Get the first location.
        double latitude = firstLocation.latitude; // Get the latitude.
        double longitude = firstLocation.longitude; // Get the longitude.

        markers.add(
          Marker(
            markerId: const MarkerId("searchedLocation"), // Add the marker to the Google Map for the searched location.
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

        final GoogleMapController controller = await _controller.future; // Get the Google Map controller.
        controller
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition)); // Animate the camera to the searched location.
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
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,  // Set the location of the floating action button.
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
        ),// Text for the app bar title.
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
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
  title: Text(
    'Emergency Alert', // Use the alert dialog for the emergency alert.
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
          color: Colors.black87, // Use a darker text color for content
          fontSize: 16.0, // Adjust the font size for readability
        ),
      ),
    ],
  ),
  actions: <Widget>[
    ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.red, // Use the same prominent color for the button
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: Text(
        'OK',
        style: TextStyle(
          color: Colors.white, // Use white text color for better contrast
        ),
      ),
    ),
  ],
);

                });
          },
          child: Container(
            margin: const EdgeInsets.all(2),
            alignment: Alignment.center,
            width: 37,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.admin_panel_settings,
              color: _isDanger ? Colors.red : Colors.black, // Use red color if the user is in a danger zone.
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
            onMapCreated: (GoogleMapController controller) { // Create the Google Map.
              _controller.complete(controller); // Complete the controller.
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
            searchLocation(searchedLocation);
          },
          icon: const Icon(Icons.search),
        ),
      ],
    );
  }

  Widget buildFloatingActionButton() {  // Build the floating action button.
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
                zoom: 14,
              );

              _userPosition_lat = value.latitude; // Set the user's current latitude.
              _userPosition_lng = value.longitude;  // Set the user's current longitude.

              final GoogleMapController controller = await _controller.future;
              controller.animateCamera(
                  CameraUpdate.newCameraPosition(cameraPosition));
              setState(() {});

              _setSOS();  // Set the SOS flag if the user is in a danger zone.
            });
          },
          child: const Icon(Icons.location_on), // Icon for current location
        ),
      ),
    );
  }
}
