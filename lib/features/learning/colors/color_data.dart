import 'package:flutter/material.dart';

import 'color_item.dart';

class ColorData {
  static const List<ColorItem> colors = [
    ColorItem(
      name: 'Red',
      color: Colors.red,
      emoji: '🍎',
    ),
    ColorItem(
      name: 'Blue',
      color: Colors.blue,
      emoji: '🫐',
    ),
    ColorItem(
      name: 'Green',
      color: Colors.green,
      emoji: '🥦',
    ),
    ColorItem(
      name: 'Yellow',
      color: Colors.amber,
      emoji: '🍌',
    ),
    ColorItem(
      name: 'Orange',
      color: Colors.orange,
      emoji: '🍊',
    ),
    ColorItem(
      name: 'Purple',
      color: Colors.purple,
      emoji: '🍇',
    ),
  ];
}