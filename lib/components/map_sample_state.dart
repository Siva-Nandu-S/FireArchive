// ignore_for_file: unnecessary_new

import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'package:fire_archive/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller =
      Completer(); // This is the controller for the Google Map.
  final TextEditingController _locationController =
      TextEditingController(); // This is the controller for the location text field.

  final Set<Marker> _markers =
      <Marker>{}; // This is the set of markers for the Google Map.
  final Set<Polygon> _polygons =
      <Polygon>{}; // This is the set of polygons for the Google Map.
  final Set<Polyline> _polylines =
      <Polyline>{}; // This is the set of polylines for the Google Map.
  List<LatLng> polygonLatLngs =
      <LatLng>[]; // This is the list of LatLngs for the polygons.

  int _polygonIdCounter = 1; // This is the counter for the polygon IDs.
  // ignore: unused_field
  final int _polylineIdCounter = 1; // This is the counter for the polyline IDs.

  // get http => null; // This is the http getter for the hotspots API.

  static const CameraPosition _kGooglePlex = CameraPosition(
    // This is the camera position for the Google Map.
    target: LatLng(20.5937,
        78.9629), // This is the target for the camera position.
    zoom: 4, // This is the zoom for the camera position.
  );

  setMarkers(locations) async {
    // This is the function to set the markers for the hotspots on the Google Map.
    print("From setMarkers Method");

    var data = locations[0].join(',').toString();
    var dataList = data.split('\n');

    for (int i = 1; i < dataList.length; i++) {
      // This is the for loop to set the markers for the hotspots.
      var newData = dataList[i].split(',');
      double latitude = double.parse(newData[1]);
      double longitude = double.parse(newData[2]);
      print('${latitude}  +  ${longitude}');
      _setMarker(
          LatLng(latitude, longitude)); // This sets the marker for the hotspot.
      Future.delayed(const Duration(seconds: 1), () {
        // This is the future function to set the marker for the hotspot.
        print("From Future Function");
      });
    }
  }

  // country_id,latitude,longitude,bright_ti4,scan,track,acq_date,acq_time,satellite,instrument,confidence,version,bright_ti5,frp,daynight

  List<List<dynamic>>? hotspots;

  @override
  void initState(){
    // This is the function to initialize the state of the Google Map widget.
    super
        .initState(); // This initializes the state of the Google Map widget with the super class.

    var client = new http.Client();
    client
        .get(Uri.parse(
            'https://firms.modaps.eosdis.nasa.gov/api/country/csv/ecc82b64df96a0490420a20ea4546b65/VIIRS_SNPP_NRT/IND/1'))
        .then((response) async {
      String data = response.body;
      List<List<dynamic>> res = const CsvToListConverter().convert(data); // This converts the CSV data to a list of lists.
      print("From Main Function");
      hotspots = res;

      Future.delayed(const Duration(seconds: 5), () {
        print("From Future Function");
        setMarkers(hotspots!);
      });
    });


    // _setMarker(const LatLng(37.42796133580664, -102.085749655962));
  }

  Future<void> _setMarker(LatLng point) async {
    // This is the function to set the marker for the hotspots on the Google Map widget.
    
    setState(() {
      // This sets the state of the Google Map widget.
      print("From _setMarker Method");
      _markers.add(
        // This adds the marker for the hotspots to the Google Map widget.
        Marker(
          markerId: const MarkerId(
              'marker'), // This is the ID for the marker for the hotspots.
          position:
              point, // This is the position for the marker for the hotspots.
        ),
      );
    });
  }

  void _setPolygon() {
    // This is the function to set the polygon for the hotspots on the Google Map widget.
    final String polygonIdVal =
        'polygon_$_polygonIdCounter'; // This is the ID for the polygon for the hotspots.
    _polygonIdCounter++; // This increments the counter for the polygon IDs for the hotspots.

    _polygons.add(
      // This adds the polygon for the hotspots to the Google Map widget to display on the Google Map.
      Polygon(
        // This is the polygon for the hotspots.
        polygonId: PolygonId(
            polygonIdVal), // This is the ID for the polygon for the hotspots.
        points:
            polygonLatLngs, // This is the list of LatLngs for the polygon for the hotspots.
        strokeWidth:
            2, // This is the width of the stroke for the polygon for the hotspots.
        fillColor: Colors
            .transparent, // This is the color of the fill for the polygon for the hotspots to be transparent.
      ),
    );
  }

  late String
      searchedLocation; // This is the searched location for the Google Map widget to display on the Google Map.

  @override
  Widget build(BuildContext context) {
    // This is the function to build the Google Map widget.
    return new Scaffold(
      // This is the scaffold for the Google Map widget.
      appBar:
          myappbar(), // This is the app bar for the Google Map widget to display on the Google Map.
      backgroundColor: Colors
          .white, // This is the background color for the Google Map widget to display on the Google Map.
      body: Column(
        children: [
          Row(
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
                            'assets/icons/loc-1.svg', // This is the icon for the location text field.
                            colorFilter: const ColorFilter.mode(
                                Color.fromARGB(255, 109, 107, 106),
                                BlendMode.srcIn),
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        searchedLocation =
                            value; // This sets the searched location for the Google Map widget to display on the Google Map.
                      },
                    ),
                    // TextFormField(
                    //   controller: _destinationController,
                    //   decoration: const InputDecoration(hintText: ' Destination'),
                    //   onChanged: (value) {
                    //     print(value);
                    //   },
                    // ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  // This is the function to search for the location on the Google Map widget.
                  // var directions = await LocationService().getDirections(
                  //   _originController.text,
                  //   _destinationController.text,
                  // );
                  // _goToPlace(
                  //   directions['start_location']['lat'],
                  //   directions['start_location']['lng'],
                  //   directions['bounds_ne'],
                  //   directions['bounds_sw'],
                  // );

                  // _setPolyline(directions['polyline_decoded']);
                },
                icon: const Icon(
                    Icons.search), // This is the icon for the search button.
              ),
            ],
          ),
          Expanded(
            child: GoogleMap(
              // This is the Google Map widget to display on the Google Map.
              mapType: MapType
                  .normal, // This is the map type for the Google Map widget to display on the Google Map.
              markers:
                  _markers, // This is the set of markers for the Google Map widget to display on the Google Map.
              polygons:
                  _polygons, // This is the set of polygons for the Google Map widget to display on the Google Map.
              polylines:
                  _polylines, // This is the set of polylines for the Google Map widget to display on the Google Map.
              initialCameraPosition:
                  _kGooglePlex, // This is the initial camera position for the Google Map widget to display on the Google Map.
              onMapCreated: (GoogleMapController controller) {
                // This is the function to create the Google Map widget to display on the Google Map.
                _controller.complete(
                    controller); // This completes the controller for the Google Map widget to display on the Google Map.
              },
              onTap: (point) {
                // This is the function to set the polygon for the hotspots on the Google Map widget.
                setState(() {
                  // This sets the state of the Google Map widget.
                  polygonLatLngs.add(
                      point); // This adds the point for the polygon for the hotspots to the Google Map widget.
                  _setPolygon(); // This sets the polygon for the hotspots on the Google Map widget.
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  AppBar myappbar() {
    // This is the app bar for the Google Map widget to display on the Google Map widget.
    return AppBar(
      // This is the app bar for the Google Map widget to display on the Google Map widget.
      title: const Text('FireArchive🔥',
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
      backgroundColor: Colors.white,
      elevation: 0.0,
      centerTitle: true,
      leading: GestureDetector(
        onTap: () {},
        child: Container(
          margin: const EdgeInsets.all(10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: SvgPicture.asset(
            'assets/icons/menu-1.svg', // This is the icon for the menu button.
            height: 40,
            width: 40,
          ),
        ),
      ),
      actions: [
        GestureDetector(
          // This is the gesture detector for the admin button on the Google Map widget.
          onTap: () {},
          child: Container(
            margin: const EdgeInsets.all(10),
            alignment: Alignment.center,
            width: 37,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: SvgPicture.asset(
              'assets/icons/admin-1.svg', // This is the icon for the admin button.
              height: 40,
              width: 40,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _goToPlace(
    // This is the function to go to the place on the Google Map widget.
    // Map<String, dynamic> place,
    double lat, // This is the latitude for the Google Map widget.
    double
        lng, // This is the function to go to the place on the Google Map widget.
    Map<String, dynamic> boundsNe,
    Map<String, dynamic> boundsSw,
  ) async {
    // final double lat = place['geometry']['location']['lat'];
    // final double lng = place['geometry']['location']['lng'];

    final GoogleMapController controller = await _controller
        .future; // This is the controller for the Google Map widget.
    controller.animateCamera(
      // This animates the camera for the Google Map widget.
      CameraUpdate.newCameraPosition(
        // This is the new camera position for the Google Map widget.
        CameraPosition(
            target: LatLng(lat, lng),
            zoom: 12), // This is the camera position for the Google Map widget.
      ),
    );

    controller.animateCamera(
      // This animates the camera for the Google Map widget.
      CameraUpdate.newLatLngBounds(
          // This is the new LatLng bounds for the Google Map widget.
          LatLngBounds(
            southwest: LatLng(
                boundsSw['lat'],
                boundsSw[
                    'lng']), // This is the southwest for the Google Map widget.
            northeast: LatLng(
                boundsNe['lat'],
                boundsNe[
                    'lng']), // This is the northeast for the Google Map widget.
          ),
          25),
    );
    _setMarker(
        LatLng(lat, lng)); // This sets the marker for the Google Map widget.
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }
}
