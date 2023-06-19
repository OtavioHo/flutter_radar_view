import 'package:example/my_custom_radar_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_radar_view/flutter_radar_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Radar View Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: false,
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

class _MyHomePageState extends State<MyHomePage> {
  List<Spot> spots = [
    Spot(distance: 100, icon: Icons.add_box_sharp),
    Spot(distance: 150, icon: Icons.comment_bank),
    Spot(distance: 200),
    Spot(distance: 250),
    Spot(distance: 300),
    Spot(distance: 350),
  ];

  final RadarController _controller = RadarController();
  double scale = 1;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          bottom: const TabBar(tabs: [
            Tab(text: 'Default Painter'),
            Tab(text: 'Custom Painter'),
          ]),
        ),
        body: TabBarView(
          children: [
            Stack(
              children: [
                Positioned.fill(
                  child: RadarView(
                    controller: _controller,
                    spots: spots,
                    initialScale: 1,
                  ),
                ),
                Positioned(
                  top: 20,
                  right: 20,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        onPressed: () {
                          _controller.animateTo(const Offset(0, 0));
                        },
                        child: const Icon(Icons.my_location),
                      ),
                      const SizedBox(height: 10),
                      FloatingActionButton(
                        onPressed: () {
                          setState(() {
                            scale = scale + 1;
                          });
                          _controller.scaleTo(scale);
                        },
                        child: const Icon(Icons.zoom_in),
                      ),
                      const SizedBox(height: 10),
                      FloatingActionButton(
                        onPressed: () {
                          setState(() {
                            scale = scale - 1;
                          });
                          _controller.scaleTo(scale);
                        },
                        child: const Icon(Icons.zoom_out),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            RadarView(
              spots: spots,
              customRadarPainter: MyCustomRadarPainter(
                rect: Rect.fromLTWH(
                  20,
                  100,
                  MediaQuery.of(context).size.width - 40,
                  MediaQuery.of(context).size.height - 250,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
