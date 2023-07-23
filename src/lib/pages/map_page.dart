import 'dart:async';
import "package:geolocator/geolocator.dart";
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Completer<GoogleMapController> _controller = Completer();
  LatLng? center;
  Set<Marker> markers = {};

  void getPosition() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    Position posit = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    setState(() {
      center = LatLng(posit.latitude, posit.longitude);
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void initState() {
    super.initState();
    getPosition();
  }

  _handleTap(LatLng tappedPoint) {
    setState(() {
      markers = {
        Marker(
          markerId: MarkerId(tappedPoint.toString()),
          position: tappedPoint,
          draggable: true,
        )
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
        centerTitle: true,
      ),
      body: GoogleMap(
        markers: markers,
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: center!,
          zoom: 10.0,
        ),
        onTap: _handleTap,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: (markers.isNotEmpty)
          ? FloatingActionButton(
              onPressed: () {
                Navigator.popAndPushNamed(context, "/tool",
                    arguments: {"position": markers.first.position});
              },
              child: Icon(Icons.check),
            )
          : null,
    );
  }
}
