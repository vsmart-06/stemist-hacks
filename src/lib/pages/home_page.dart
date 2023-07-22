import "package:flutter/material.dart";
import "package:geolocator/geolocator.dart";
import "package:http/http.dart";

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  Position? position;

  Future<Position> getPosition() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    return position;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tourio"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            TextButton(
              child: Text("Get landmarks"),
              onPressed: () {
                setState(() async {
                  position = await getPosition();
                });
              },
            )
          ],
        )
      )
    );
  }
}