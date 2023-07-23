import "package:flutter/material.dart";
import "package:geolocator/geolocator.dart";
import "package:http/http.dart";
import "dart:convert";

import "package:loading_animation_widget/loading_animation_widget.dart";

String base_url = "http://127.0.0.1:5000";
class Tool extends StatefulWidget {
  const Tool({super.key});

  @override
  State<Tool> createState() => _ToolState();
}

class _ToolState extends State<Tool> {
  var data;
  dynamic position;
  List<Widget> landmarks = [];
  List<String> landmark_names = [];
  List<bool> pressed = [];
  List<dynamic> autocomplete = [];
  String floating_data = "";
  late double width;
  late double height;
  String location = "";
  ScrollController controller = ScrollController();

  void getAutocomplete(String place) async {
    Response response = await get(Uri.parse(base_url + "/autocomplete"),
        headers: {"place": place});
    var temp_autocomplete = jsonDecode(response.body)["autocomplete"];
    setState(() {
      autocomplete = temp_autocomplete;
      landmarks = [];
      landmark_names = [];
      pressed = [];
    });
  }

  Widget autocompleteColumn() {
    return Container(
      height: autocomplete.isEmpty ? null : height * 0.2,
      child: RawScrollbar(
        controller: controller,
        isAlwaysShown: true,
        thumbColor: Colors.black,
        child: SingleChildScrollView(
          controller: controller,
          child: Column(
            children: [
              Container(
                width: width * 0.9,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Card(
                    color: Colors.lightBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.lightBlue)),
                    child: TextButton.icon(
                      onPressed: () {
                        getPosition();
                      },
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all<Color>(Colors.white)
                      ),
                      label: Text(
                        "Current Location",
                        style: TextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                      icon: Icon(Icons.location_on)
                    ),
                  ),
                ),
              ),
              Column(
                children: autocomplete.map<Container>((var name) {
                  return Container(
                    width: width * 0.9,
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.lightBlue)),
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            generateLandmarks(name);
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            name,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void getPosition() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    Position posit = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    setState(() {
      position = posit;
      generateLandmarks(null);
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
                  child: floating_data.isEmpty ? Center(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LoadingAnimationWidget.newtonCradle(color: Colors.blue, size: 200),
                      Text("Generating...")
                    ],
                  )) : SingleChildScrollView(
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

  void generateLandmarks(String? place) async {
    List<Widget> temp_landmarks = [];
    List<String> temp_string_landmarks = [];
    List<bool> temp_pressed = [];
    late Response response;
    if (place == null) {
      response = await get(Uri.parse(base_url + "/landmarks"), headers: {
        "latitude": position!.latitude.toString(),
        "longitude": position!.longitude.toString()
      });
    } else {
      response = await get(Uri.parse(base_url + "/landmarks"),
          headers: {"place": place});
    }
    var landmark_data = jsonDecode(response.body)["landmarks"];
    for (Map landmark in landmark_data) {
      temp_pressed.add(false);
      int index = landmark_data.indexOf(landmark);
      temp_string_landmarks.add(landmark["name"]);
      Container card = Container(
        width: width * 0.8,
        height: height * 0.12,
        child: ElevatedButton(
          style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20))),
              elevation: MaterialStateProperty.all<double>(20)),
          onPressed: () async {
            setState(() {
                          pressed[index] = true;
            });
            String details = await getInformation(landmark["name"]);
            setState(() {
              floating_data = details;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  landmark["name"],
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  landmark["vicinity"],
                  textAlign: TextAlign.center,
                  style: TextStyle(fontStyle: FontStyle.italic),
                )
              ],
            ),
          ),
        ),
      );
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
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    data = ModalRoute.of(context)!.settings.arguments as Map?;
  }

  @override
  Widget build(BuildContext context) {
    if (data != null) {
      setState(() {
              position = data["position"];
              generateLandmarks(null);
              data = null;
            });
    }
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
              height: 80,
              child: DrawerHeader(
                child: Text(
                  "Tourio",
                  style: TextStyle(
                    color: Colors.black
                  )
                )
              ),
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
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: IconButton(
                        icon: Icon(Icons.my_location),
                        onPressed: () {
                          Navigator.pushNamed(context, "/map");
                        },
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Location",
                        ),
                        onChanged: (value) {
                          setState(() {
                            location = value;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () async {
                          location.isEmpty ? null : getAutocomplete(location);
                        },
                      ),
                    ),
                  ]),
                ),
                autocompleteColumn(),
                Expanded(
                  child: Container(
                    width: width,
                    child: SingleChildScrollView(
                      child: Column(
                        children: landmarks,
                      ),
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
