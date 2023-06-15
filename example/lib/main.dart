import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_radar_view/flutter_radar_view.dart';
import 'package:touchable/touchable.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _offsetAnimationController;
  late Tween<Offset> _offsetTween;
  late Animation<Offset> _offsetAnimation;
  Offset _currentOffset = const Offset(0, 0);
  bool _dragable = true;
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  void initState() {
    _offsetAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _offsetTween = Tween(begin: Offset.zero, end: Offset.zero);
    _offsetAnimation = _offsetTween.animate(_offsetAnimationController)
      ..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  void animateToNewPosition(Offset position) {
    _dragable = false;
    _offsetTween.begin = _currentOffset;
    _offsetAnimationController.reset();
    _offsetTween.end = position;
    _offsetAnimationController.forward();
    _currentOffset = position;
  }

  double scale = 1.0;
  List<Spot> spots = [
    Spot(distance: 100, icon: Icons.add_box_sharp),
    Spot(distance: 150, icon: Icons.comment_bank),
    Spot(distance: 200),
    Spot(distance: 250),
    Spot(distance: 300),
    Spot(distance: 350),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      drawer: const Drawer(),
      body: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onScaleUpdate: (details) {
                    setState(() {
                      _dragable = true;
                      _currentOffset = _currentOffset.translate(
                        details.focalPointDelta.dx,
                        details.focalPointDelta.dy,
                      );
                    });

                    if (details.pointerCount == 2) {
                      setState(() {
                        scale = details.scale;
                      });
                    }
                  },
                  child: CanvasTouchDetector(
                    gesturesToOverride: const [GestureType.onTapDown],
                    builder: (context) => CustomPaint(
                      painter: RadarPainter(
                        onTapSpot: (spot, details) =>
                            animateToNewPosition(Offset(
                          -spot.distance * cos(spot.angle) * scale,
                          -spot.distance * sin(spot.angle) * scale,
                        )),
                        context: context,
                        offset:
                            _dragable ? _currentOffset : _offsetAnimation.value,
                        scale: scale,
                        spots: spots,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
