import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:text_scroll/text_scroll.dart';

const text = 'ABCDEFGHIJKLMNOPQRST';
const style = TextStyle(fontSize: 10, color: Color(0xFF000000));
const velocity = Velocity(pixelsPerSecond: Offset(100, 0));
const tick = Duration(milliseconds: 50);
const second = Duration(seconds: 1);
const boundaryKey = Key('boundary');

Future<void> mount(
  WidgetTester tester,
  TextScroll widget, {
  double width = 100,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Center(
        child: RepaintBoundary(
          key: boundaryKey,
          child: SizedBox(width: width, child: widget),
        ),
      ),
    ),
  );
}

TextScroll scroll({
  String content = text,
  TextScrollMode mode = TextScrollMode.endless,
  Velocity velocity = velocity,
  TextDirection textDirection = TextDirection.ltr,
  int? numberOfReps,
  int? intervalSpaces,
  Duration? delayBefore,
  Duration? pauseBetween,
  Duration? pauseOnBounce,
  bool selectable = false,
  bool fadedBorder = false,
  FadeBorderSide fadeBorderSide = FadeBorderSide.both,
  FadeBorderVisibility fadeBorderVisibility = FadeBorderVisibility.auto,
}) {
  return TextScroll(
    content,
    style: style,
    mode: mode,
    velocity: velocity,
    textDirection: textDirection,
    numberOfReps: numberOfReps,
    intervalSpaces: intervalSpaces,
    delayBefore: delayBefore,
    pauseBetween: pauseBetween,
    pauseOnBounce: pauseOnBounce,
    selectable: selectable,
    fadedBorder: fadedBorder,
    fadeBorderSide: fadeBorderSide,
    fadeBorderVisibility: fadeBorderVisibility,
  );
}

double offset(WidgetTester tester) => tester
    .widget<SingleChildScrollView>(find.byType(SingleChildScrollView))
    .controller!
    .offset;

String shown(WidgetTester tester) =>
    tester.widget<Text>(find.byType(Text)).data!;

Future<List<double>> sample(WidgetTester tester, Duration total) async {
  final offsets = <double>[];
  for (var i = 0; i < total.inMilliseconds ~/ tick.inMilliseconds; i++) {
    await tester.pump(tick);
    offsets.add(offset(tester));
  }
  return offsets;
}

int longestRunAt(List<double> offsets, double value) {
  var longest = 0;
  var run = 0;
  for (final o in offsets) {
    run = (o - value).abs() < 0.5 ? run + 1 : 0;
    if (run > longest) longest = run;
  }
  return longest;
}

int restAfterFirstJumpBack(List<double> offsets) {
  final jump = offsets.indexed
      .skip(1)
      .firstWhere((e) => e.$2 < offsets[e.$1 - 1])
      .$1;
  return offsets.skip(jump).takeWhile((o) => o == 0).length;
}

/// Pauses and delays are plain futures that outlive dispose.
Future<void> unmountAndDrain(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(second + tick);
}

double maxOf(List<double> offsets) => offsets.reduce(max);

Future<List<int>> alphasAt(WidgetTester tester, List<int> xs) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(boundaryKey),
  );
  final image = (await tester.runAsync(boundary.toImage))!;
  final bytes = (await tester.runAsync(
    () => image.toByteData(format: ui.ImageByteFormat.rawRgba),
  ))!;
  final row = image.height ~/ 2;
  return [for (final x in xs) bytes.getUint8((row * image.width + x) * 4 + 3)];
}

void main() {
  group('endless mode', () {
    testWidgets('scrolls the text doubled, one round, then jumps back', (
      tester,
    ) async {
      await mount(tester, scroll());
      final offsets = await sample(tester, const Duration(seconds: 3));

      expect(shown(tester), '$text\u00A0$text');
      expect(maxOf(offsets), closeTo(210, 10));
      expect(restAfterFirstJumpBack(offsets), lessThan(5));
    });

    testWidgets('moves at the given velocity', (tester) async {
      await mount(tester, scroll());
      await sample(tester, second);
      final before = offset(tester);
      await sample(tester, const Duration(milliseconds: 500));

      expect(offset(tester) - before, closeTo(50, 1));
    });

    testWidgets('intervalSpaces sets the gap between the copies', (
      tester,
    ) async {
      await mount(tester, scroll(intervalSpaces: 3));
      await sample(tester, second);

      expect(shown(tester), '$text\u00A0\u00A0\u00A0$text');
    });

    testWidgets('pauseBetween holds at the start between rounds', (
      tester,
    ) async {
      await mount(tester, scroll(pauseBetween: second));
      final offsets = await sample(tester, const Duration(seconds: 4));

      expect(restAfterFirstJumpBack(offsets), inInclusiveRange(18, 24));
      await unmountAndDrain(tester);
    });

    testWidgets(
      'numberOfReps: 1 never scrolls, the setup round counts as a rep',
      (tester) async {
        await mount(tester, scroll(numberOfReps: 1));
        final offsets = await sample(tester, const Duration(seconds: 3));

        expect(maxOf(offsets), 0);
      },
    );

    testWidgets('numberOfReps: 2 scrolls one round, then stops', (
      tester,
    ) async {
      await mount(tester, scroll(numberOfReps: 2));
      final offsets = await sample(tester, const Duration(seconds: 5));

      expect(maxOf(offsets), closeTo(210, 10));
      expect(offsets.skip(offsets.length - 40), everyElement(0));
    });
  });

  group('bouncing mode', () {
    testWidgets('scrolls to the end and back, text not doubled', (
      tester,
    ) async {
      await mount(tester, scroll(mode: TextScrollMode.bouncing));
      final offsets = await sample(tester, const Duration(seconds: 3));

      expect(shown(tester), text);
      expect(maxOf(offsets), closeTo(100, 0.5));
      expect(offsets.skipWhile((o) => o < 100), contains(0));
    });

    testWidgets('pauseOnBounce holds at the end', (tester) async {
      await mount(
        tester,
        scroll(mode: TextScrollMode.bouncing, pauseOnBounce: second),
      );
      final offsets = await sample(tester, const Duration(seconds: 4));

      expect(longestRunAt(offsets, 100), inInclusiveRange(18, 24));
      await unmountAndDrain(tester);
    });

    testWidgets('pauseBetween holds at the start between round trips', (
      tester,
    ) async {
      await mount(
        tester,
        scroll(mode: TextScrollMode.bouncing, pauseBetween: second),
      );
      final offsets = await sample(tester, const Duration(seconds: 4));

      expect(
        longestRunAt(offsets.skip(10).toList(), 0),
        inInclusiveRange(18, 24),
      );
      await unmountAndDrain(tester);
    });

    testWidgets('numberOfReps: 1 makes one round trip, then stops', (
      tester,
    ) async {
      await mount(
        tester,
        scroll(mode: TextScrollMode.bouncing, numberOfReps: 1),
      );
      final offsets = await sample(tester, const Duration(seconds: 4));

      expect(maxOf(offsets), closeTo(100, 0.5));
      expect(offsets.skip(offsets.length - 20), everyElement(0));
    });
  });

  for (final mode in TextScrollMode.values) {
    testWidgets('${mode.name} mode: delayBefore postpones the first move', (
      tester,
    ) async {
      await mount(tester, scroll(mode: mode, delayBefore: second));
      final offsets = await sample(tester, const Duration(seconds: 2));

      expect(offsets.take(19), everyElement(0));
      expect(offsets.last, greaterThan(0));
    });

    testWidgets('${mode.name} mode: text that fits does not scroll or double', (
      tester,
    ) async {
      await mount(tester, scroll(mode: mode, content: 'ABC'));
      final offsets = await sample(tester, const Duration(seconds: 3));

      expect(shown(tester), 'ABC');
      expect(maxOf(offsets), 0);
    });
  }

  group('text direction', () {
    Future<double> textShift(
      WidgetTester tester,
      TextDirection direction,
    ) async {
      await mount(tester, scroll(textDirection: direction));
      await sample(tester, const Duration(milliseconds: 500));
      final start = tester.getTopLeft(find.byType(Text)).dx;
      await sample(tester, const Duration(milliseconds: 500));
      return tester.getTopLeft(find.byType(Text)).dx - start;
    }

    testWidgets('ltr moves the text to the left', (tester) async {
      expect(await textShift(tester, TextDirection.ltr), closeTo(-50, 1));
    });

    testWidgets('rtl moves the text to the right', (tester) async {
      expect(await textShift(tester, TextDirection.rtl), closeTo(50, 1));
    });
  });

  group('faded border', () {
    testWidgets('off by default', (tester) async {
      await mount(tester, scroll());
      await tester.pump();

      expect(find.byType(ShaderMask), findsNothing);
    });

    testWidgets('auto: fades long text only', (tester) async {
      await mount(tester, scroll(fadedBorder: true));
      await tester.pump();
      expect(find.byType(ShaderMask), findsOneWidget);

      await mount(tester, scroll(fadedBorder: true, content: 'ABC'));
      await tester.pump();
      expect(find.byType(ShaderMask), findsNothing);
    });

    testWidgets('always: fades text that fits too', (tester) async {
      await mount(
        tester,
        scroll(
          fadedBorder: true,
          content: 'ABC',
          fadeBorderVisibility: FadeBorderVisibility.always,
        ),
      );
      await tester.pump();

      expect(find.byType(ShaderMask), findsOneWidget);
    });

    const edges = [0, 50, 99];
    final expectedAlphas = {
      FadeBorderSide.left: [lessThan(16), 255, 255],
      FadeBorderSide.right: [255, 255, lessThan(16)],
      FadeBorderSide.both: [lessThan(16), 255, lessThan(16)],
    };
    for (final side in FadeBorderSide.values) {
      testWidgets('fadeBorderSide ${side.name} fades only its edges', (
        tester,
      ) async {
        await mount(
          tester,
          scroll(fadedBorder: true, fadeBorderSide: side, delayBefore: second),
        );
        await tester.pump();

        expect(await alphasAt(tester, edges), expectedAlphas[side]);
        await unmountAndDrain(tester);
      });
    }
  });

  testWidgets('selectable renders SelectableText', (tester) async {
    await mount(tester, scroll(selectable: true));
    await tester.pump();

    expect(find.byType(SelectableText), findsOneWidget);
  });

  group('updates', () {
    testWidgets('endless: a text change restarts from the start', (
      tester,
    ) async {
      await mount(tester, scroll());
      await sample(tester, second);
      await mount(tester, scroll(content: 'abcdefghijklmnopqrstuvwxyz'));
      await tester.pump();

      expect(offset(tester), 0);
      await sample(tester, second);
      expect(
        shown(tester),
        'abcdefghijklmnopqrstuvwxyz\u00A0abcdefghijklmnopqrstuvwxyz',
      );
    });

    testWidgets(
      'bouncing: a text change mid-trip does not reset the scroll (#44)',
      (tester) async {
        await mount(tester, scroll(mode: TextScrollMode.bouncing));
        await sample(tester, const Duration(milliseconds: 800));
        final before = offset(tester);
        await mount(
          tester,
          scroll(
            mode: TextScrollMode.bouncing,
            content: 'abcdefghijklmnopqrstuvwxyz',
          ),
        );
        await tester.pump(tick);

        expect(offset(tester), greaterThan(before));
      },
    );

    testWidgets('keeps scrolling after the box grows to fit the text (#40)', (
      tester,
    ) async {
      await mount(tester, scroll());
      await sample(tester, second);
      await mount(tester, scroll(), width: 300);
      final offsets = await sample(tester, const Duration(seconds: 3));

      expect(shown(tester), '$text\u00A0$text');
      expect(maxOf(offsets), greaterThan(100));
    });
  });

  testWidgets('a negative velocity trips the duration > zero assertion (#43)', (
    tester,
  ) async {
    final errors = <Object>[];
    await runZonedGuarded(() async {
      await mount(
        tester,
        scroll(velocity: const Velocity(pixelsPerSecond: Offset(-100, 0))),
      );
      await sample(tester, const Duration(milliseconds: 300));
    }, (error, _) => errors.add(error));

    expect(errors, [
      isAssertionError.having(
        (e) => e.toString(),
        'toString()',
        contains('duration > Duration.zero'),
      ),
    ]);
  });

  group('dispose', () {
    testWidgets('unmounting mid-scroll leaves no timer running', (
      tester,
    ) async {
      await mount(tester, scroll());
      await sample(tester, second);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets(
      'unmounting during delayBefore: the delay runs on and starts a timer '
      'that stops itself on its first tick',
      (tester) async {
        await mount(tester, scroll(delayBefore: second));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 500) + tick);
      },
    );
  });
}
