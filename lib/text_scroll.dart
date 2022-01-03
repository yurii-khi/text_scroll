library text_scroll;

import 'dart:async';

import 'package:flutter/material.dart';

class TextScroll extends StatefulWidget {
  const TextScroll(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.numberOfReps,
    this.delayBefore,
    this.pauseBetween,
    this.mode = TextScrollMode.endless,
    this.velocity = const Velocity(pixelsPerSecond: Offset(80, 0)),
  }) : super(key: key);

  final String text;
  final TextAlign? textAlign;
  final TextStyle? style;
  final int? numberOfReps;
  final Duration? delayBefore;
  final Duration? pauseBetween;
  final TextScrollMode mode;
  final Velocity velocity;

  @override
  State<TextScroll> createState() => _TextScrollState();
}

class _TextScrollState extends State<TextScroll> {
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
  void didUpdateWidget(covariant TextScroll oldWidget) {
    _onUpdate(oldWidget);

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(
        widget.pauseBetween == null || widget.mode == TextScrollMode.bouncing,
        'pauseBetween is only available for TextScrollMode.bouncing mode');

    return Flexible(
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        child: Text(
          _endlessText ?? widget.text,
          style: widget.style,
          textAlign: widget.textAlign,
        ),
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
        case TextScrollMode.bouncing:
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

  void _onUpdate(TextScroll oldWidget) {
    if (widget.text != oldWidget.text && _endlessText != null) {
      setState(() => _endlessText = null);
      _scrollController.jumpTo(_scrollController.position.minScrollExtent);
    }
  }
}

enum TextScrollMode {
  bouncing,
  endless,
}
