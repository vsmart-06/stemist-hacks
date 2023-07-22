import "package:flutter/material.dart";
import "package:geolocator/geolocator.dart";
import "package:http/http.dart";
import "dart:convert";

String base = "https://tourio-api.onrender.com";

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  Position? position;
  List<Widget> landmarks= [];

  void getPosition() async {
    Position posit = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    print(posit);
    setState(() {
      position = posit;
    });
  }

  /* void generateLandmarks () async {
    landmarks = [];

    Response response = await get(Uri.parse(base + "/landmarks"));
    List<Map> landmark_data = jsonDecode(response.body);

    for (Map landmark in landmark_data) {
      landmarks.add(
        Text(
          landmark["name"]
        )
      );
    }
  } */

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
              onPressed: () async {
                getPosition();
              },
            ),
            Column(
              children: landmarks,
            )
          ],
        )
      )
    );
  }
}