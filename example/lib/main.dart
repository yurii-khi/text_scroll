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
          children: const <Widget>[
            TextScroller(
              'This is the sample text for Flutter TextScroller plugin. '
              'This is the sample text for Flutter TextScroller plugin.',
            ),
            TextScroller(
              'This is the sample text for Flutter TextScroller plugin, '
              'showing \'numberOfReps\' parameter (2 reps).',
              numberOfReps: 2,
            ),
            TextScroller('This is the sample text'),
          ],
        ),
      ),
    );
  }
}
