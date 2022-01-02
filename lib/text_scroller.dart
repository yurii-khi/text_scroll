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
    this.pauseBetween,
    this.mode = TextScrollerMode.endless,
    this.velocity = const Velocity(pixelsPerSecond: Offset(80, 0)),
  }) : super(key: key);

  final String text;
  final TextStyle? style;
  final int? numberOfReps;
  final Duration? delayBefore;
  final Duration? pauseBetween;
  final TextScrollerMode mode;
  final Velocity velocity;

  @override
  State<TextScroller> createState() => _TextScrollerState();
}

class _TextScrollerState extends State<TextScroller> {
  final _scrollController = ScrollController();
  String? _endlessText;
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
    assert(
        widget.pauseBetween == null || widget.mode == TextScrollerMode.bouncing,
        'pauseBetween is only available for TextScrollerMode.bouncing mode');

    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: Text(
        _endlessText ?? widget.text,
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

      switch (widget.mode) {
        case TextScrollerMode.bouncing:
          {
            await _animateBouncing();
            break;
          }
        default:
          {
            await _animateEndless();
          }
      }
    }

    _running = false;
  }

  Future<void> _animateEndless() async {
    if (!mounted) return;

    final ScrollPosition position = _scrollController.position;
    final bool needsScrolling = position.maxScrollExtent > 0;
    if (!needsScrolling) {
      if (_endlessText != null) setState(() => _endlessText = null);
      return;
    }

    if (_endlessText == null) {
      setState(() => _endlessText = widget.text + ' ' + widget.text);
      return;
    }

    final double singleRoundExtent =
        (position.maxScrollExtent + position.viewportDimension) / 2;
    final Duration duration = _getDuration(singleRoundExtent);
    if (duration == Duration.zero) return;

    if (!mounted) return;
    await _scrollController.animateTo(
      singleRoundExtent,
      duration: duration,
      curve: Curves.linear,
    );
    if (!mounted) return;
    _scrollController.jumpTo(position.minScrollExtent);
  }

  Future<void> _animateBouncing() async {
    final double maxExtent = _scrollController.position.maxScrollExtent;
    final double minExtent = _scrollController.position.minScrollExtent;
    final double extent = maxExtent - minExtent;
    final Duration duration = _getDuration(extent);
    if (duration == Duration.zero) return;

    if (!mounted) return;
    await _scrollController.animateTo(
      maxExtent,
      duration: duration,
      curve: Curves.linear,
    );
    if (!mounted) return;
    await _scrollController.animateTo(
      minExtent,
      duration: duration,
      curve: Curves.linear,
    );
    if (!mounted) return;
    if (widget.pauseBetween != null) {
      await Future<dynamic>.delayed(widget.pauseBetween!);
    }
  }

  Future<void> _delayBefore() async {
    final Duration? delayBefore = widget.delayBefore;
    if (delayBefore == null) return;

    await Future<dynamic>.delayed(delayBefore);
  }

  Duration _getDuration(double extent) {
    final int milliseconds =
        (extent * 1000 / widget.velocity.pixelsPerSecond.dx).round();

    return Duration(milliseconds: milliseconds);
  }
}

enum TextScrollerMode {
  bouncing,
  endless,
}
