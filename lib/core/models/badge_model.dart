import 'package:flutter/material.dart';

class BadgeModel {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int requiredLessons;

  const BadgeModel({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.requiredLessons,
  });
}
