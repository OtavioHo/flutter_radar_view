import 'dart:math';

import 'package:flutter/material.dart';

class Spot {
  final double distance;
  late double theta;
  final IconData icon;

  Spot({required this.distance, this.icon = Icons.add}) {
    theta = Random().nextDouble() * 2 * pi;
  }
}
