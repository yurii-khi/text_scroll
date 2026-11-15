import 'dart:async';

// ignore: deprecated_member_use
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
    super.key,
    this.style,
    this.textAlign,
    this.textDirection = TextDirection.ltr,
    this.numberOfReps,
    this.delayBefore,
    this.pauseBetween,
    this.pauseOnBounce,
    this.mode = TextScrollMode.endless,
    this.velocity = const Velocity(pixelsPerSecond: Offset(80, 0)),
    this.selectable = false,
    this.intervalSpaces,
    this.fadedBorder = false,
    this.fadedBorderWidth = 0.2,
    this.fadeBorderSide = FadeBorderSide.both,
    this.fadeBorderVisibility = FadeBorderVisibility.auto,
  });

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
  /// Default is `null`, no limit.
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

  /// Determines pause interval before changing direction on a bounce.
  ///
  /// Default is [Duration.zero].
  ///
  /// ### Example:
  ///
  /// ```dart
  /// TextScroll(
  ///   'Pause animation when text reaches the end',
  ///   mode: TextScrollMode.bouncing,
  ///   pauseOnBounce: Duration(milliseconds: 300),
  /// )
  /// ```
  final Duration? pauseOnBounce;

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
  /// ```
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

  /// Adds blank spaces between two nearby text sentences
  /// in case of [TextScrollMode.endless]
  ///
  /// Default is `1`.
  ///
  /// Example:
  ///
  /// ```dart
  /// TextScroll(
  ///   'This is the sample text for Flutter TextScroll widget. ',
  ///   intervalSpaces: 10,
  /// )
  /// ```
  final int? intervalSpaces;

  /// Fades the text out to the left and right edges of the widget.
  /// Default is `false`.
  ///
  /// Example:
  ///
  /// ```dart
  /// TextScroll(
  ///   'This is the sample text for Flutter TextScroll widget. ',
  ///   fadedBorder: true,
  /// )
  /// ```
  final bool fadedBorder;

  /// Sets width of the faded border.
  /// Default is `0.2`.
  ///
  /// Example:
  ///
  /// ```dart
  /// TextScroll(
  ///   'This is the sample text for Flutter TextScroll widget. ',
  ///   fadedBorder: true,
  ///   fadedBorderWidth: 0.25,
  /// )
  /// ```
  final double? fadedBorderWidth;

  /// Sets which side of the widget should be faded.
  /// Default is [FadeBorderSide.both].
  ///
  /// Example:
  ///
  /// ```dart
  /// TextScroll(
  ///  'This is the sample text for Flutter TextScroll widget. ',
  ///  fadedBorder: true,
  ///  fadeBorderSide: FadeBorderSide.left,
  ///  )
  ///  ```
  final FadeBorderSide fadeBorderSide;

  /// Sets when the fadeBorder should be shown.
  /// Default is [FadeBorderVisibility.auto].
  ///
  /// Example:
  ///
  /// ```dart
  /// TextScroll(
  ///  'This is the sample text for Flutter TextScroll widget. ',
  ///  fadedBorder: true,
  ///  fadeBorderVisibility: FadeBorderVisibility.always,
  ///  )
  ///  ```
  final FadeBorderVisibility fadeBorderVisibility;

  @override
  State<TextScroll> createState() => _TextScrollState();
}

class _TextScrollState extends State<TextScroll> {
  final _scrollController = ScrollController();
  final Set<Timer> _waits = {};
  String? _endlessText;
  double? _originalTextWidth;
  double? _textMinWidth;
  Timer? _timer;
  bool _running = false;
  int _counter = 0;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(covariant TextScroll oldWidget) {
    super.didUpdateWidget(oldWidget);
    final Paint paint = Paint();
    TextStyle layoutOf(TextStyle? style) => (style ?? const TextStyle())
        .copyWith(foreground: paint, background: paint);
    if (widget.text != oldWidget.text ||
        widget.mode != oldWidget.mode ||
        widget.velocity != oldWidget.velocity ||
        widget.intervalSpaces != oldWidget.intervalSpaces ||
        layoutOf(widget.style).compareTo(layoutOf(oldWidget.style)) ==
            RenderComparison.layout) {
      _restart();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final wait in _waits) {
      wait.cancel();
    }
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(
      widget.intervalSpaces == null || widget.mode == TextScrollMode.endless,
      'intervalSpaces is only available in TextScrollMode.endless mode',
    );
    assert(
      !widget.fadedBorder ||
          (widget.fadedBorder &&
              widget.fadedBorderWidth != null &&
              widget.fadedBorderWidth! > 0 &&
              widget.fadedBorderWidth! <= 1),
      'fadedBorderInterval must be between 0 and 1 when fadedBorder is true',
    );

    Widget baseWidget = Directionality(
      textDirection: widget.textDirection,
      child: NotificationListener<ScrollMetricsNotification>(
        onNotification: _onMetricsChanged,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: NeverScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: _textMinWidth ?? 0),
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
        ),
      ),
    );

    /// Used to add the fade border effect, if enabled
    Widget? fadeBorderWidget;

    /// If fade border is enabled
    if (widget.fadedBorder) {
      ///Fill list with amount of transparent colors to make the text visible
      final List<Color> colors = List.generate(
        1 ~/ widget.fadedBorderWidth! - 1,
        (index) {
          return Colors.transparent;
        },
        growable: true,
      );

      ///Add black color to add gradient fade out
      if (widget.fadeBorderSide == FadeBorderSide.both ||
          widget.fadeBorderSide == FadeBorderSide.left) {
        colors.insert(0, Colors.black);
      } else {
        colors.add(Colors.transparent);
      }
      if (widget.fadeBorderSide == FadeBorderSide.both ||
          widget.fadeBorderSide == FadeBorderSide.right) {
        colors.add(Colors.black);
      } else {
        colors.add(Colors.transparent);
      }

      ///Calculate the stops for the gradient
      final List<double> stops = List.generate(1 ~/ widget.fadedBorderWidth!, (
        index,
      ) {
        return (index + 1) * widget.fadedBorderWidth!;
      }, growable: true);

      ///Add first stop to list
      stops.insert(0, 0);

      /// Pre-render text to get it's width
      final TextPainter textPrototype = TextPainter(
        text: TextSpan(text: _endlessText ?? widget.text, style: widget.style),
        textDirection: widget.textDirection,
        textScaler: MediaQuery.of(context).textScaler,
        textWidthBasis: TextWidthBasis.longestLine,
      )..layout();

      ///Apply ShaderMask to the text
      fadeBorderWidget = LayoutBuilder(
        builder: (context, constraints) {
          ///When text is wider than the widget, apply ShaderMask
          if (widget.fadeBorderVisibility == FadeBorderVisibility.always ||
              constraints.maxWidth < textPrototype.size.width) {
            return ShaderMask(
              blendMode: BlendMode.dstOut,
              shaderCallback: (rect) {
                return LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: colors,
                  stops: stops,
                ).createShader(rect);
              },
              child: baseWidget,
            );
          } else {
            ///When text is smaller than the widget, just return the text
            return baseWidget;
          }
        },
      );
    }

    return fadeBorderWidget ?? baseWidget;
  }

  Future<void> _start() async {
    await _wait(widget.delayBefore);
    if (!mounted) return;
    _startTicking();
  }

  void _startTicking() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      final int? maxReps = widget.numberOfReps;
      if (maxReps != null && _counter >= maxReps) {
        timer.cancel();
      } else if (!_running && _hasDimensions) {
        _run();
      }
    });
  }

  Future<void> _run() async {
    _running = true;
    final int generation = _generation;
    final bool completed = widget.mode == TextScrollMode.bouncing
        ? await _animateBouncing(generation)
        : await _animateEndless(generation);
    if (generation != _generation) return;
    if (completed) _counter++;
    _running = false;
  }

  Future<bool> _animateEndless(int generation) async {
    final ScrollPosition position = _scrollController.position;
    if (position.maxScrollExtent <= 0) {
      if (_endlessText != null) setState(() => _endlessText = null);
      return true;
    }

    if (_endlessText == null) {
      setState(() {
        _originalTextWidth =
            position.maxScrollExtent + position.viewportDimension;
        _endlessText =
            widget.text +
            '\u{00A0}' * (widget.intervalSpaces ?? 1) +
            widget.text;
      });
      return false;
    }

    final double singleRoundExtent =
        position.maxScrollExtent +
        position.viewportDimension -
        _originalTextWidth!;
    final Duration duration = _getDuration(singleRoundExtent);
    if (duration <= Duration.zero) {
      return widget.velocity.pixelsPerSecond.dx <= 0;
    }

    await _scrollController.animateTo(
      singleRoundExtent,
      duration: duration,
      curve: Curves.linear,
    );
    if (_isStale(generation)) return false;
    _scrollController.jumpTo(position.minScrollExtent);
    await _wait(widget.pauseBetween);
    return !_isStale(generation);
  }

  Future<bool> _animateBouncing(int generation) async {
    final ScrollPosition position = _scrollController.position;
    final double maxExtent = position.maxScrollExtent;
    final double minExtent = position.minScrollExtent;
    final Duration duration = _getDuration(maxExtent - minExtent);
    if (duration <= Duration.zero) return true;

    await _scrollController.animateTo(
      maxExtent,
      duration: duration,
      curve: Curves.linear,
    );
    if (_isStale(generation)) return false;
    await _wait(widget.pauseOnBounce);
    if (_isStale(generation)) return false;
    await _scrollController.animateTo(
      minExtent,
      duration: duration,
      curve: Curves.linear,
    );
    if (_isStale(generation)) return false;
    await _wait(widget.pauseBetween);
    return !_isStale(generation);
  }

  Future<void> _wait(Duration? duration) {
    if (duration == null) return Future.value();
    final completer = Completer<void>();
    late final Timer timer;
    timer = Timer(duration, () {
      _waits.remove(timer);
      completer.complete();
    });
    _waits.add(timer);
    return completer.future;
  }

  Duration _getDuration(double extent) {
    if (widget.velocity.pixelsPerSecond.dx <= 0) return Duration.zero;

    final int milliseconds =
        (extent * 1000 / widget.velocity.pixelsPerSecond.dx).round();

    return Duration(milliseconds: milliseconds);
  }

  bool _onMetricsChanged(ScrollMetricsNotification notification) {
    if (notification.depth == 0 && _textMinWidth == null) {
      setState(() => _textMinWidth = notification.metrics.viewportDimension);
    }
    return false;
  }

  void _restart() {
    final int generation = ++_generation;
    _counter = 0;
    if (_timer?.isActive == false) _startTicking();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isStale(generation)) return;
      if (_hasDimensions) {
        _scrollController.jumpTo(_scrollController.position.minScrollExtent);
      }
      _running = false;
    });
    _endlessText = null;
  }

  bool _isStale(int generation) => generation != _generation || !mounted;

  bool get _hasDimensions =>
      _scrollController.hasClients && _scrollController.position.haveDimensions;
}

/// Animation types for [TextScroll] widget.
///
/// [endless] - scrolls text in one direction endlessly.
///
/// [bouncing] - when text is scrolled to its end,
/// starts animation to opposite direction.
enum TextScrollMode { bouncing, endless }

/// Side of the text border to fade out.
///
/// [left] - fade out left side of the text.
/// [right] - fade out right side of the text.
/// [both] - fade out both sides of the text.
enum FadeBorderSide { left, right, both }

/// Sets when the fade border will be applied
///
/// [always] - always show the border, independent of the text length
/// [auto] - show the border only when the text is wider than the widget
enum FadeBorderVisibility { always, auto }
