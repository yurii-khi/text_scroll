library text_scroller;

import 'dart:async';

import 'package:flutter/material.dart';

class TextScroller extends StatefulWidget {
  const TextScroller(
    this.text, {
    Key? key,
    this.style,
    this.numberOfReps,
    this.delayBefore,
  }) : super(key: key);

  final String text;
  final TextStyle? style;
  final int? numberOfReps;
  final Duration? delayBefore;

  @override
  State<TextScroller> createState() => _TextScrollerState();
}

class _TextScrollerState extends State<TextScroller> {
  final _scrollController = ScrollController();
  Timer? _timer;
  bool _running = false;
  int _counter = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback(_initScroller);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: Text(
        widget.text,
        style: widget.style,
      ),
    );
  }

  Future<void> _initScroller(_) async {
    await _delayBefore();

    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final int? maxReps = widget.numberOfReps;
      if (maxReps != null && _counter >= maxReps) {
        timer.cancel();
        return;
      }

      if (!_running) _run();
    });
  }

  Future<void> _run() async {
    _running = true;

    final int? maxReps = widget.numberOfReps;
    if (maxReps == null || _counter < maxReps) {
      _counter++;

      await _animateBouncing();
    }

    _running = false;
  }

  Future<void> _animateBouncing() async {
    if (!mounted) return;
    await _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 2),
      curve: Curves.linear,
    );
    if (!mounted) return;
    await _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: const Duration(seconds: 2),
      curve: Curves.linear,
    );
  }

  Future<void> _delayBefore() async {
    final Duration? delayBefore = widget.delayBefore;
    if (delayBefore == null) return;

    await Future<dynamic>.delayed(delayBefore);
  }
}
