import "package:flutter/material.dart";
import "package:tourio/pages/tool_page.dart";
import "package:tourio/pages/map_page.dart";
import "package:tourio/pages/checklist_page.dart";
import "package:tourio/pages/home_page.dart";

void main() {
  runApp(
    MaterialApp(
      routes: {
        "/": (context) => Home(),
        "/tool": (context) => Tool(), 
        "/map": (context) => MapPage(),
        "/checklist": (context) => Checklist()
      }
    )
  );
}