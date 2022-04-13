import 'package:flutter/material.dart';

class PageSettings extends ChangeNotifier {
  bool _isAnimated = false;
  ScrollPhysics? _physics;
  int _bottomSelected = 1;
  final PageController controller = PageController(initialPage: 1);
  final int _duration = 300;
  final Curve _curve = Curves.linear;

  void modifyIndex(int i, bool animate) {
    if (i == _bottomSelected) {
      return;
    }
    if (animate) {
      _bottomSelected = i;
      _isAnimated = true;
      _physics = const NeverScrollableScrollPhysics();
      controller.animateToPage(
        i,
        duration: Duration(milliseconds: _duration),
        curve: _curve,
      );
      Future.delayed(Duration(milliseconds: _duration), () {
        _isAnimated = false;
        _physics = null;
        notifyListeners();
      });
    } else if (!_isAnimated) {
      _bottomSelected = i;
    }
    notifyListeners();
  }

  int getBottomIndex() => _bottomSelected;
  ScrollPhysics? getScrollPhysics() => _physics;
}
