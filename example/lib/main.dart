import 'package:flutter/material.dart';
import 'package:text_scroller/text_scroller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter TextScroller Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter TextScroller'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const TextScroller(
              'This is the sample text for Flutter TextScroller plugin. ',
              velocity: Velocity(pixelsPerSecond: Offset(100, 0)),
              delayBefore: Duration(milliseconds: 50),
            ),
            const TextScroller(
              'This is the sample text for Flutter TextScroller plugin, '
              'showing \'numberOfReps\' parameter (2 reps).',
              numberOfReps: 2,
              style: TextStyle(decoration: TextDecoration.underline),
              mode: TextScrollerMode.bouncing,
              pauseBetween: Duration(milliseconds: 500),
            ),
            const TextScroller('This is the sample text'),
            FutureBuilder<dynamic>(
                future: Future<dynamic>.delayed(const Duration(seconds: 2)),
                builder: (context, snapshot) {
                  return TextScroller(snapshot.connectionState ==
                          ConnectionState.waiting
                      ? 'This is the sample text for Flutter TextScroller plugin.'
                      : 'Short text');
                }),
          ],
        ),
      ),
    );
  }
}
