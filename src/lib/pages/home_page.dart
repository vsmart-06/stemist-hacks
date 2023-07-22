import "package:flutter/material.dart";
import "package:geolocator/geolocator.dart";
import "package:http/http.dart";
import "dart:convert";

String base_url = "http://10.0.2.2:5000";

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Position? position;
  List<Widget> landmarks = [];
  List<String> landmark_names = [];
  List<bool> pressed = [];
  String floating_data = "";
  late double width;
  late double height;

  void getPosition() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    Position posit = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    setState(() {
      position = posit;
      generateLandmarks();
    });
  }

  Future<String> getInformation(String location) async {
    Response info = await get(Uri.parse(base_url + "/details"),
        headers: {"landmark": location});
    
    String details = jsonDecode(info.body)["details"];
    return details;
  }

  Widget floatCard() {
    int index = pressed.indexOf(true);
    if (index != -1) {
      return Stack(
        children: [
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Color(0x99000000),
            ),
          ),
          TapRegion(
            onTapOutside: (event) {
              setState(() {
                pressed[pressed.indexOf(true)] = false;
              });
            },
            child: Center(
                child: Container(
              width: width * 0.75,
              height: height * 0.75,
              child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.white)),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                            child: Text(landmark_names[index],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                            ),
                          ),
                          Text(floating_data)
                        ],
                      ),
                    ),
                  )),
            )),
          ),
        ],
      );
    }
    return Container();
  }

  void generateLandmarks() async {
    List<Widget> temp_landmarks = [];
    List<String> temp_string_landmarks = [];
    List<bool> temp_pressed = [];

    Response response = await get(Uri.parse(base_url + "/landmarks"), headers: {
      "latitude": position!.latitude.toString(),
      "longitude": position!.longitude.toString()
    });
    var landmark_data = jsonDecode(response.body)["landmarks"];

    for (Map landmark in landmark_data) {
      temp_pressed.add(false);
      int index = landmark_data.indexOf(landmark);
      temp_string_landmarks.add(landmark["name"]);
      Card card = Card(
          elevation: 20,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)
          ),
          child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: TextButton(
          onPressed: () async {
            String details = await getInformation(landmark["name"]);
            setState(() {
              pressed[index] = true;
              floating_data = details;
            });
          },
          child: Column(
            children: [Text(landmark["name"]), Text(landmark["vicinity"])],
          ),
        ),
      ));
      temp_landmarks.add(Padding(
        padding: const EdgeInsets.all(10.0),
        child: card,
      ));
    }

    setState(() {
      landmarks = temp_landmarks;
      pressed = temp_pressed;
      landmark_names = temp_string_landmarks;
    });
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          title: Text("Tourio"),
          centerTitle: true,
        ),
        body: Center(
            child: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: [
            Column(
              children: [
                TextButton.icon(
                  label: Text("Get landmarks"),
                  icon: Icon(Icons.search),
                  onPressed: () async {
                    getPosition();
                  },
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: landmarks,
                    ),
                  ),
                )
              ],
            ),
            floatCard(),
          ],
        )));
  }
}
