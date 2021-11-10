import 'package:adhoc_gaming/game/game_constants.dart';
import 'package:flutter/material.dart';

class GameWidgets {
  Widget ledButton(GameColors color) {
    Color materialColor;
    switch (color) {
      case GameColors.Blue:
        materialColor = BLUE_COLOR;
        break;
      case GameColors.Green:
        materialColor = GREEN_COLOR;
        break;
      case GameColors.Red:
        materialColor = RED_COLOR;
        break;
      case GameColors.Yellow:
        materialColor = YELLOW_COLOR;
        break;
      case GameColors.Default:
        materialColor = DEFAULT_COLOR;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(50.0),
        color: materialColor,
      ),
      width: 30,
      height: 30,
    );
  }
}
