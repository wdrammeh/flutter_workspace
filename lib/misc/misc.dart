import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    title: "Demo",
    home: Home(),
  ));
}

class Home extends StatelessWidget {
  Home({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Demo"
        ),
      ),
      body: GestureDetector(
        onTap: () => print("onTap"),
        onPanUpdate: (details) {
          final dx = details.delta.dx;
          final dy = details.delta.dy;
          print((dx > 0 ? "Right" : "Left") + (dy > 0 ? "Down" : "Up"));
        },
      ),
    );
  }
}
