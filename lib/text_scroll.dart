library text_scroll;

import 'dart:async';

import 'package:flutter/material.dart';

/// TextScroll widget automatically scrolls provided [text] according
/// to custom settings, in order to achieve 'marquee' text effect.
///
/// ### Example:
///
/// ```dart
/// TextScroll(
///     'This is the sample text for Flutter TextScroll widget. ',
///     mode: TextScrollMode.bouncing,
///     velocity: Velocity(pixelsPerSecond: Offset(150, 0)),
///     delayBefore: Duration(milliseconds: 500),
///     numberOfReps: 5,
///     pauseBetween: Duration(milliseconds: 50),
///     style: TextStyle(color: Colors.green),
///     textAlign: TextAlign.right,
///     selectable: true,
/// )
/// ```
class TextScroll extends StatefulWidget {
  const TextScroll(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.textDirection = TextDirection.ltr,
    this.numberOfReps,
    this.delayBefore,
    this.pauseBetween,
    this.mode = TextScrollMode.endless,
    this.velocity = const Velocity(pixelsPerSecond: Offset(80, 0)),
    this.selectable = false,
  }) : super(key: key);

  /// The text string, that would be scrolled.
  /// In case text does fit into allocated space, it wouldn't be scrolled
  /// and would be shown as is.
  ///
  /// ### Example:
  ///
  /// ```dart
  /// TextScroll('This is the sample text for Flutter TextScroll widget.')
  /// ```
  final String text;

  /// Provides [TextAlign] alignment if text string is not long enough to be scrolled.
  ///
  /// ### Example:
  ///
  /// ```dart
  /// TextScroll(
  ///   'Short string',
  ///   textAlign: TextAlign.right,
  /// )
  /// ```
  final TextAlign? textAlign;

  /// Provides [TextDirection] - a direction in which text flows.
  /// Default is [TextDirection.ltr].
  /// Default scrolling direction would be opposite to [textDirection],
  /// e.g. for [TextDirection.rtl] scrolling would be from left to right
  ///
  /// ### Example:
  ///
  /// ```dart
  /// TextScroll(
  ///   'Hey! I\'m a RTL text, check me out. Hey! I\'m a RTL text, check me out. Hey! I\'m a RTL text, check me out. ',
  ///   textDirection: TextDirection.rtl,
  /// )
  /// ```
  final TextDirection textDirection;

  /// Allows to apply custom [TextStyle] to [text].
  ///
  /// `null` by default.
  ///
  /// ### Example:
  ///
  /// ```dart
  /// TextScroll(
  ///   'Styled text',
  ///   style: TextStyle(
  ///     color: Colors.red,
  ///   ),
  /// )
  /// ```
  final TextStyle? style;

  /// Limits number of scroll animation rounds.
  ///
  /// Default is [infinity].
  ///
  /// ### Example:
  ///
  /// ```dart
  /// TextScroll(
  ///   'Limit scroll rounds to 10',
  ///   numberOfReps: 10,
  /// )
  /// ```
  final int? numberOfReps;

  /// Delay before first animation round.
  ///
  /// Default is [Duration.zero].
  ///
  /// ### Example:
  ///
  /// ```dart
  /// TextScroll(
  ///   'Start animation after 1 sec delay',
  ///   delayBefore: Duration(seconds: 1),
  /// )
  /// ```
  final Duration? delayBefore;

  /// Determines pause interval between animation rounds.
  ///
  /// Only allowed if [mode] is set to [TextScrollMode.bouncing].
  ///
  /// Default is [Duration.zero].
  ///
  /// ### Example:
  ///
  /// ```dart
  /// TextScroll(
  ///   'Pause animation between rounds',
  ///   mode: TextScrollMode.bouncing,
  ///   pauseBetween: Duration(milliseconds: 300),
  /// )
  /// ```
  final Duration? pauseBetween;

  /// Sets one of two different types of scrolling behavior.
  ///
  /// [TextScrollMode.endless] - default, scrolls text in one direction endlessly.
  ///
  /// [TextScrollMode.bouncing] - when [text] string is scrolled to its end,
  /// starts animation to opposite direction.
  ///
  /// ### Example:
  ///
  /// ```dart
  /// TextScroll(
  ///   'Animate text string back and forth',
  ///   mode: TextScrollMode.bouncing,
  /// )
  /// ```
  final TextScrollMode mode;

  /// Allows to customize animation speed.
  ///
  /// Default is `Velocity(pixelsPerSecond: Offset(80, 0))`
  ///
  /// ### Example:
  ///
  /// ```dart
  /// TextScroll(
  ///   'Animate text at 200px per second',
  ///   velocity: Velocity(pixelsPerSecond: Offset(200, 0)),
  /// )
  final Velocity velocity;

  /// Allows users to select provided [text], copy it to clipboard etc.
  ///
  /// Default is `false`.
  ///
  /// Example:
  ///
  /// ```dart
  /// TextScroll(
  ///   'Selectable text',
  ///   selectable: true,
  /// )
  /// ```
  final bool selectable;

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

    return Directionality(
      textDirection: widget.textDirection,
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        child: widget.selectable
            ? SelectableText(
                _endlessText ?? widget.text,
                style: widget.style,
                textAlign: widget.textAlign,
              )
            : Text(
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

/// Animation types for [TextScroll] widget.
///
/// [endless] - scrolls text in one direction endlessly.
///
/// [bouncing] - when text is scrolled to its end,
/// starts animation to opposite direction.
enum TextScrollMode {
  bouncing,
  endless,
}
