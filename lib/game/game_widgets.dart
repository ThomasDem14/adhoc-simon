import 'package:flutter/material.dart';

class GameWidgets {

  Widget ledButton(Color color) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(5.0),
        color: color,
      ),
      child: Text("O"),
    );
  }
}