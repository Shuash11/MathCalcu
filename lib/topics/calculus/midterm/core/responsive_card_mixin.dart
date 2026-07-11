import 'package:flutter/material.dart';

mixin ResponsiveCardMixin<T extends StatefulWidget> on State<T> {
  static const double _baseDesignWidth = 400.0;

  double get scaleFactor {
    final width = MediaQuery.of(context).size.width;
    return (width / _baseDesignWidth).clamp(0.7, 1.2);
  }

  double scale(double value) => value * scaleFactor;

  double get s => scaleFactor;
}
