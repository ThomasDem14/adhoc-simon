import 'package:adhoc_gaming/game/game_constants.dart';
import 'package:flutter/material.dart';

class GameWidgets extends StatelessWidget {

  final Widget child;
  final ValueGetter<GameColors> onPressed;

  GameWidgets({this.onPressed, this.child});

  Color _getColor(GameColors color) {
    Color returnColor;
    switch (color) {
      case GameColors.Blue:
        returnColor = BLUE_COLOR;
        break;
      case GameColors.Green:
        returnColor = GREEN_COLOR;
        break;
      case GameColors.Red:
        returnColor = RED_COLOR;
        break;
      case GameColors.Yellow:
        returnColor = YELLOW_COLOR;
        break;
      case GameColors.Default:
        returnColor = DEFAULT_COLOR;
        break;
    }
    return returnColor;
  }

  Color _getColorToDisplay(GameColors color, GameColors compare) {
    if (color == compare)
      return _getColor(color);
    return _getColor(GameColors.Default);
  }

  Widget _ledButton(GameColors initialColor, GameColors onPressedColor) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: _getColor(initialColor),
          width: 10,
        ),
        borderRadius: BorderRadius.circular(100.0),
        color: _getColorToDisplay(onPressedColor, initialColor),
      ),
      width: 90,
      height: 90,
    );
  }

  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ledButton(GameColors.Blue, onPressed()),
              _ledButton(GameColors.Red, onPressed()),
            ],
          ),
        ),
        child,
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ledButton(GameColors.Yellow, onPressed()),
              _ledButton(GameColors.Green, onPressed()),
            ],
          ),
        ),
      ],
    );
  }
}
