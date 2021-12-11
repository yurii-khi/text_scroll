library text_scroller;

import 'package:flutter/material.dart';

class TextScroller extends StatefulWidget {
  const TextScroller({Key? key, required this.text}) : super(key: key);

  final String text;

  @override
  _TextScrollerState createState() => _TextScrollerState();
}

class _TextScrollerState extends State<TextScroller> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.text);
  }
}
