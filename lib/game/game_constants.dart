import 'package:flutter/material.dart';

enum GameColors {
  Red,
  Blue,
  Green,
  Yellow,
  Default,
}

GameColors getGameColorsFromString(String colorString) {
  if (colorString == "Red")
    return GameColors.Red;
  else if (colorString == "Blue")
    return GameColors.Blue;
  else if (colorString == "Green")
    return GameColors.Green;
  else if (colorString == "Yellow")
    return GameColors.Yellow;
  else if (colorString == "Default")
    return GameColors.Default;
  else
    return null;
}

const RED_COLOR = Colors.red;
const BLUE_COLOR = Colors.blue;
const GREEN_COLOR = Colors.green;
const YELLOW_COLOR = Colors.yellow;

const DEFAULT_COLOR = Colors.black;
