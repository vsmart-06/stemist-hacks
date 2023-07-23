import "package:flutter/material.dart";
import "package:http/http.dart";
import "package:geolocator/geolocator.dart";
import "dart:convert";
import 'package:loading_animation_widget/loading_animation_widget.dart';
import "package:permission_handler/permission_handler.dart";

String base_url = "http://10.0.2.2:5000";

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String city = "";
  String details = "";

  void getPosition() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    await Permission.phone.request();

    generateDetails(position);
  }

  void generateDetails(Position position) async {
    Response response =
        await get(Uri.parse(base_url + "/city-details"), headers: {
      "latitude": position.latitude.toString(),
      "longitude": position.longitude.toString()
    });
    var data = jsonDecode(response.body);
    setState(() {
      city = data["city"];
      details = data["details"];
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Tourio"), centerTitle: true),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                height: 80,
                child: DrawerHeader(
                    child:
                        Text("Tourio", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
              ),
              ListTile(
                title: Text(
                  "Home",
                ),
                onTap: () {
                  Navigator.popAndPushNamed(context, "/");
                },
              ),
              ListTile(
                title: Text(
                  "Tool",
                ),
                onTap: () {
                  Navigator.popAndPushNamed(context, "/tool");
                },
              ),
              ListTile(
                title: Text(
                  "Checklist",
                ),
                onTap: () {
                  Navigator.popAndPushNamed(context, "/checklist");
                },
              ),
            ],
          ),
        ),
        body: Center(
            child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: SingleChildScrollView(
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: city == ""
                    ? LoadingAnimationWidget.staggeredDotsWave(
                        color: Colors.blue, size: 200)
                    : Text("Welcome to $city!"),
              ),
              details == "" ? Text("Generating...") : Text(details)
            ]),
          ),
        )));
  }
}
