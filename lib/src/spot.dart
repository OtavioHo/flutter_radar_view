import 'dart:math';

import 'package:flutter/material.dart';

class Spot {
  final double distance;
  late double angle;
  final IconData icon;

  Spot({required this.distance, this.icon = Icons.add}) {
    angle = Random().nextDouble() * 2 * pi;
  }
}
