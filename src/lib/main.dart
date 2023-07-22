import "package:flutter/material.dart";
import "package:tourio/pages/home_page.dart";

void main() {
  runApp(
    MaterialApp(
      routes: {
        "/": (context) => Home()
      }
    )
  );
}