import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:movam/constants/images.dart';
import 'package:movam/constants/texts.dart';

class HomePage extends StatefulWidget {
  static const id = "HomePage";

  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> _controller = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  var location;
  var myLocations;

  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;

  Marker? marker;
  Circle? circle;
  List<Marker> _markers = [];

  Future<Uint8List> getMarker() async {
    ByteData byteData = await DefaultAssetBundle.of(context).load(kAppMarker);
    return byteData.buffer.asUint8List();
  }

  Future getLocations() async {
    final response = await http
        .get(
          Uri.parse("https://enpuyr7bafpswlw.m.pipedream.net/"),
        )
        .timeout(Duration(seconds: 20));
    myLocations = json.decode(response.body);
    print(myLocations.length);
    List<Marker> markers = myLocations.map((n) async {
      LatLng point = LatLng(n.lat, n.lng);

      return Marker(
          markerId: MarkerId(n['name']),
          position: point,
          //rotation: newPosition.heading,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: const Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(await getMarker()));
    }).toList();

    setState(() {
      _markers.clear();
      _markers = [...markers];
    });
  }

  StreamSubscription<Position>? positionStream;

  void updateMarkerAndCircle(Position newPosition, Uint8List imageData) {
    LatLng latLng = LatLng(newPosition.latitude, newPosition.longitude);
    setState(() {
      marker = Marker(
          markerId: const MarkerId("home"),
          position: latLng,
          rotation: newPosition.heading,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: const Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData));
      circle = Circle(
          circleId: const CircleId("id"),
          radius: newPosition.accuracy,
          zIndex: 1,
          strokeColor: Colors.blue,
          center: latLng,
          fillColor: Colors.blue.withAlpha(70));
      _markers.add(marker!);
    });
  }

  Position? currentPosition;
  var geoLocator = Geolocator();

  void locatePosition() async {
    Uint8List imageData = await getMarker();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

    updateMarkerAndCircle(position, imageData);
    LatLng latlngPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: latlngPosition, zoom: 14);
    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    positionStream = Geolocator.getPositionStream(
            locationSettings:
                const LocationSettings(accuracy: LocationAccuracy.best))
        .listen((Position listeningPosition) {
      if (newGoogleMapController != null) {
        newGoogleMapController!
            .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          bearing: 192.8334901395799,
          target:
              LatLng(listeningPosition.latitude, listeningPosition.longitude),
          tilt: 0,
          zoom: 15.00,
        )));
      }
      // write method that automatically updates users positions here
      updateMarkerAndCircle(listeningPosition, imageData);
    });
  }

  static final CameraPosition _initialCameraPosition =
      CameraPosition(target: LatLng(kInitialLat, kInitialLon), zoom: 14.4746);

  @override
  void initState() {
    super.initState();
    setState(() {
      location = getLocations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GoogleMap(
          mapToolbarEnabled: false,
          mapType: MapType.normal,
          myLocationButtonEnabled: true,
          initialCameraPosition: _initialCameraPosition,
          myLocationEnabled: true,
          //markers: Set.of((marker != null) ? [marker!] : []),
          markers: Set.of(_markers),
          circles: Set.of((circle != null) ? [circle!] : []),
          zoomGesturesEnabled: true,
          zoomControlsEnabled: true,
          onMapCreated: (GoogleMapController controller) {
            _controllerGoogleMap.complete(controller);
            newGoogleMapController = controller;
            print("Done bros --------------------------- flllf ---------");
            locatePosition();
          },
        ),
      ),
    );
  }
}
