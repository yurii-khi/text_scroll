import 'package:flutter/material.dart';
import 'package:text_scroll/text_scroll.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter TextScroll Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter TextScroll'),
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
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                children: const [
                  TextScroll(
                    'This is the sample text for Flutter TextScroll plugin. ',
                    velocity: Velocity(pixelsPerSecond: Offset(150, 0)),
                    mode: TextScrollMode.bouncing,
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: TextScroll(
                      'This is the sample text for Flutter TextScroll widget.',
                      velocity: Velocity(pixelsPerSecond: Offset(50, 0)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const TextScroll(
                'This is the sample text for Flutter TextScroll widget. '
                'This is the sample text for Flutter TextScroll widget.',
                mode: TextScrollMode.bouncing,
                numberOfReps: 200,
                delayBefore: Duration(milliseconds: 2000),
                pauseBetween: Duration(milliseconds: 1000),
                velocity: Velocity(pixelsPerSecond: Offset(100, 0)),
                style: TextStyle(decoration: TextDecoration.underline),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
