import 'package:flutter/material.dart';
import 'package:flutter_radar_view/flutter_radar_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('RadarView should render correctly', (WidgetTester tester) async {
    // Arrange
    final spots = [
      Spot(size: 10.0, icon: Icons.ac_unit, distance: 10),
      Spot(size: 20.0, icon: Icons.access_alarm, distance: 20),
    ];

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RadarView(
            spots: spots,
            initialScale: 1.0,
            isDragable: true,
            onTapSpot: (spot, details) {},
          ),
        ),
      ),
    );

    // Assert
    expect(find.byType(RadarView), findsOneWidget);
  });
}
