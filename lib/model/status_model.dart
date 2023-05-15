import 'package:flutter/material.dart';

class StatusModel {
  final int level;

  final String name;

  final Color primaryColor;

  final Color darkColor;

  final Color lightColor;

  final Color detailFontColor;

  final String imagePath;

  final String comment;

  final double minFineDust;

  final double minUltraFineDust;

  final double minO3;

  final double minNO2;

  final double minCO;

  final double minSO2;

  StatusModel({
    required this.level,
    required this.name,
    required this.primaryColor,
    required this.darkColor,
    required this.lightColor,
    required this.detailFontColor,
    required this.imagePath,
    required this.comment,
    required this.minFineDust,
    required this.minUltraFineDust,
    required this.minO3,
    required this.minNO2,
    required this.minCO,
    required this.minSO2,
  });
}
