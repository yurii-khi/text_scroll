library text_scroller;

import 'package:flutter/material.dart';

class TextScroller extends StatefulWidget {
  const TextScroller({
    Key? key,
    required this.text,
    this.numberOfReps,
    this.delayBefore,
  }) : super(key: key);

  final String text;
  final int? numberOfReps;
  final Duration? delayBefore;

  @override
  State<TextScroller> createState() => _TextScrollerState();
}

class _TextScrollerState extends State<TextScroller> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _run();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: Text(widget.text),
    );
  }

  Future<void> _run() async {
    final Duration delayBefore =
        widget.delayBefore ?? const Duration(seconds: 0);
    await Future<dynamic>.delayed(delayBefore);

    final int? maxReps = widget.numberOfReps;

    for (int i = 0; i < (maxReps ?? 99999); i++) {
      await _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 2),
        curve: Curves.linear,
      );
      if (!mounted) break;
      await _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(seconds: 2),
        curve: Curves.linear,
      );
    }
  }
}
