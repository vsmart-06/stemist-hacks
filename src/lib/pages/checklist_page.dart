import 'package:flutter/material.dart';
import "package:http/http.dart";
import "dart:convert";
import 'package:device_information/device_information.dart';

String base_url = "http://10.0.2.2:5000";

class Checklist extends StatefulWidget {
  @override
  _ChecklistState createState() => _ChecklistState();
}

class _ChecklistState extends State<Checklist> {
  List<String> items = [];
  List<bool> pressed = [];
  String device_id = "";

  void deleteItem(int index) async {
    String item = items.removeAt(index);
    bool press = pressed.removeAt(index);
    String caps_press =
        "${press.toString()[0].toUpperCase()}${press.toString().substring(1).toLowerCase()}";
    setState(() {
      items = items;
      pressed = pressed;
    });
    await delete(Uri.parse(base_url + "/delete-task"),
        headers: {"user": device_id, "task": "['$item', $caps_press]"});
  }

  void loadItems() async {
    items = [];
    pressed = [];
    var t = await get(Uri.parse(base_url + "/get-tasks"),
        headers: {"user": device_id});
    var data = jsonDecode(t.body)["tasks"];
    if (data == null) {
      return;
    }
    for (List x in data) {
      items.add(x[0]);
      pressed.add(x[1]);
    }
    setState(() {
      items = items;
      pressed = pressed;
    });
  }

  void getDeviceId() async {
    var deviceId = await DeviceInformation.deviceIMEINumber;
    setState(() {
      device_id = deviceId;
    });
    loadItems();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDeviceId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tourio'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 80,
              child: DrawerHeader(
                  child: Text("Tourio", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
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
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: ValueKey<List>([items[index], index]),
            onDismissed: (direction) {
              deleteItem(index);
            },
            child: Card(
              child: CheckboxListTile(
                value: pressed[index],
                onChanged: (bool? new_value) async {
                  setState(() {
                    pressed[index] = new_value!;
                  });
                  String caps_pressed =
                      "${new_value.toString()[0].toUpperCase()}${new_value.toString().substring(1).toLowerCase()}";
                  await patch(Uri.parse(base_url + "/update-task"), headers: {
                    "user": device_id,
                    "task": "['${items[index]}', $caps_pressed]",
                    "pressed": caps_pressed
                  });
                },
                title: Text(items[index]),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
          );
        },
      ),
    );
  }
}
