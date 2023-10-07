import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'package:fire_archive/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class MapSampleState extends State<MapSample> {

  final Completer<GoogleMapController> _controller =
      Completer(); // Controller for the Google Map.
  final TextEditingController _locationController =
      TextEditingController(); // Controller for the location text field.
  List<List<dynamic>>? locations; // List of hotspot locations.

  // Constants
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(20.42796133580664, 80.885749655962),
    zoom: 1,
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
            'https://firms.modaps.eosdis.nasa.gov/api/country/csv/ecc82b64df96a0490420a20ea4546b65/VIIRS_SNPP_NRT/IND/1'))
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

      spots += <Marker>[
        Marker(
            markerId: MarkerId(i.toString()),
            position: LatLng(latitude, longitude),
            infoWindow: const InfoWindow(
              title: '',
            )),
      ];
    }
    setState(() {
      markers.addAll(spots);
    });
  }



  @override
  void dispose() {
    // Dispose of resources here.
    _locationController.dispose();
    super.dispose();
  }

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission().then((value) {}).onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      print("ERROR: $error");
    });
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      backgroundColor: Colors.white,
      body: buildBody(),
      floatingActionButton: buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: const Text(
        'FireArchive🔥',
        style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.white,
      elevation: 0.0,
      centerTitle: true,
      leading: GestureDetector(
        onTap: () {},
        child: Container(
          margin: const EdgeInsets.all(10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: SvgPicture.asset(
            'assets/icons/menu-1.svg',
            height: 40,
            width: 40,
          ),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {},
          child: Container(
            margin: const EdgeInsets.all(10),
            alignment: Alignment.center,
            width: 37,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SvgPicture.asset(
              'assets/icons/admin-1.svg',
              height: 40,
              width: 40,
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
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
              ),
            );

            CameraPosition cameraPosition = CameraPosition(
              target: LatLng(value.latitude, value.longitude),
              zoom: 14,
            );

            final GoogleMapController controller = await _controller.future;
            controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
            setState(() {});
          });
        },
        child: const Icon(Icons.local_activity),
      ),
    );
  }
}
