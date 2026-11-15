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

Future<void> mount(WidgetTester tester, Widget widget) {
  return tester.pumpWidget(
    MaterialApp(
      home: Center(
        child: RepaintBoundary(
          key: boundaryKey,
          child: SizedBox(width: 100, child: widget),
        ),
      ),
    ),
  );
}

TextScroll scroll({
  String content = text,
  TextStyle textStyle = style,
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
    style: textStyle,
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

int jumpBacks(List<double> offsets) => [
  for (var i = 1; i < offsets.length; i++) offsets[i] < offsets[i - 1],
].where((jumped) => jumped).length;

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
    });

    testWidgets('a first frame later than a tick does not use up a round', (
      tester,
    ) async {
      await mount(tester, scroll(numberOfReps: 1));
      await tester.pump(const Duration(milliseconds: 500));
      final offsets = await sample(tester, const Duration(seconds: 3));

      expect(maxOf(offsets), closeTo(210, 10));
    });

    for (final reps in [1, 2]) {
      testWidgets('numberOfReps: $reps scrolls that many rounds, then stops', (
        tester,
      ) async {
        await mount(tester, scroll(numberOfReps: reps));
        final offsets = await sample(tester, const Duration(seconds: 7));

        expect(maxOf(offsets), closeTo(210, 10));
        expect(jumpBacks(offsets), reps);
        expect(offsets.last, 0);
      });
    }
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
      });
    }
  });

  testWidgets('selectable short text renders SelectableText at full width', (
    tester,
  ) async {
    await mount(tester, scroll(content: 'ABC', selectable: true));
    await tester.pump();

    expect(
      tester.getSize(find.byType(SelectableText)).width,
      greaterThanOrEqualTo(100),
    );
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

    testWidgets('bouncing: a text change mid-trip resets the scroll (#44)', (
      tester,
    ) async {
      await mount(tester, scroll(mode: TextScrollMode.bouncing));
      await sample(tester, const Duration(milliseconds: 800));
      await mount(
        tester,
        scroll(
          mode: TextScrollMode.bouncing,
          content: 'abcdefghijklmnopqrstuvwxyz',
        ),
      );
      await tester.pump();
      expect(offset(tester), 0);

      final offsets = await sample(tester, const Duration(seconds: 3));
      expect(maxOf(offsets), closeTo(160, 0.5));
    });

    testWidgets('bouncing: a text change during pauseOnBounce restarts', (
      tester,
    ) async {
      TextScroll bounce(String content) => scroll(
        content: content,
        mode: TextScrollMode.bouncing,
        pauseOnBounce: const Duration(seconds: 2),
      );
      await mount(tester, bounce(text));
      await sample(tester, const Duration(milliseconds: 1250));
      await mount(tester, bounce('abcdefghijklmnopqrstuvwxyz'));
      final offsets = await sample(tester, const Duration(seconds: 4));

      expect(offsets.last, 130);
    });

    testWidgets('a text change during delayBefore still scrolls after it', (
      tester,
    ) async {
      await mount(tester, scroll(delayBefore: second));
      await tester.pump(const Duration(milliseconds: 500));
      await mount(
        tester,
        scroll(delayBefore: second, content: 'abcdefghijklmnopqrstuvwxyz'),
      );
      final offsets = await sample(tester, const Duration(seconds: 2));

      expect(maxOf(offsets), greaterThan(50));
    });

    testWidgets('a font size change mid-scroll re-measures the round', (
      tester,
    ) async {
      await mount(tester, scroll());
      await sample(tester, second);
      await mount(tester, scroll(textStyle: style.copyWith(fontSize: 7)));
      final offsets = await sample(tester, const Duration(seconds: 3));

      expect(maxOf(offsets), closeTo(147, 8));
    });

    testWidgets('a parent rebuilding with a fresh Paint completes the round', (
      tester,
    ) async {
      final rebuilds = ValueNotifier(0);
      await mount(
        tester,
        ValueListenableBuilder<int>(
          valueListenable: rebuilds,
          builder: (_, _, _) => scroll(
            textStyle: TextStyle(
              fontSize: 10,
              foreground: Paint()..color = const Color(0xFF000000),
            ),
          ),
        ),
      );
      final offsets = <double>[];
      for (var i = 0; i < 12; i++) {
        rebuilds.value++;
        offsets.addAll(await sample(tester, const Duration(milliseconds: 250)));
      }

      expect(maxOf(offsets), closeTo(210, 10));
      expect(jumpBacks(offsets), 1);
    });

    testWidgets('switching between a Paint and a color does not restart', (
      tester,
    ) async {
      final offsets = <double>[];
      for (final textStyle in [
        TextStyle(fontSize: 10, foreground: Paint()),
        const TextStyle(fontSize: 10, color: Color(0xFF000000)),
        const TextStyle(fontSize: 10),
        TextStyle(fontSize: 10, background: Paint()),
        const TextStyle(fontSize: 10, backgroundColor: Color(0xFFFFFFFF)),
      ]) {
        await mount(tester, scroll(textStyle: textStyle));
        offsets.addAll(await sample(tester, const Duration(milliseconds: 300)));
      }

      expect(jumpBacks(offsets), 0);
      expect(maxOf(offsets), closeTo(150, 10));
    });

    testWidgets('a mode change restarts in the new mode', (tester) async {
      await mount(tester, scroll());
      await sample(tester, second);
      await mount(tester, scroll(mode: TextScrollMode.bouncing));
      final offsets = await sample(tester, const Duration(seconds: 3));

      expect(shown(tester), text);
      expect(maxOf(offsets), closeTo(100, 0.5));
    });

    testWidgets('an intervalSpaces change restarts with the new gap', (
      tester,
    ) async {
      await mount(tester, scroll());
      await sample(tester, second);
      await mount(tester, scroll(intervalSpaces: 3));
      await tester.pump();
      expect(offset(tester), 0);

      final offsets = await sample(tester, const Duration(seconds: 3));
      expect(shown(tester), '$text\u00A0\u00A0\u00A0$text');
      expect(maxOf(offsets), closeTo(230, 10));
    });

    testWidgets('a text change counts numberOfReps from zero', (tester) async {
      await mount(tester, scroll(numberOfReps: 2));
      await sample(tester, const Duration(seconds: 3));
      await mount(
        tester,
        scroll(numberOfReps: 2, content: 'abcdefghijklmnopqrstuvwxyz'),
      );
      final offsets = await sample(tester, const Duration(seconds: 7));

      expect(jumpBacks(offsets), 2);
    });

    testWidgets('a text change scrolls again after numberOfReps ran out', (
      tester,
    ) async {
      await mount(tester, scroll(numberOfReps: 1));
      await sample(tester, const Duration(seconds: 3));
      await mount(
        tester,
        scroll(numberOfReps: 1, content: 'abcdefghijklmnopqrstuvwxyz'),
      );
      final offsets = await sample(tester, const Duration(seconds: 4));

      expect(maxOf(offsets), closeTo(270, 10));
      expect(jumpBacks(offsets), 1);
    });

    for (final (label, raised, rounds) in [
      ('to 2 resumes for one more round', 2, 1),
      ('to null resumes', null, 2),
    ]) {
      testWidgets('raising numberOfReps from 1 $label', (tester) async {
        await mount(tester, scroll(numberOfReps: 1));
        await sample(tester, const Duration(seconds: 3));
        await mount(tester, scroll(numberOfReps: raised));
        final offsets = await sample(tester, const Duration(seconds: 5));

        expect(maxOf(offsets), closeTo(210, 10));
        expect(jumpBacks(offsets), rounds);
      });
    }

    testWidgets('lowering numberOfReps mid-round does not restart', (
      tester,
    ) async {
      await mount(tester, scroll(numberOfReps: 3));
      await sample(tester, second);
      final before = offset(tester);
      await mount(tester, scroll(numberOfReps: 1));
      final offsets = await sample(tester, const Duration(seconds: 4));

      expect(offsets.first, greaterThan(before));
      expect(jumpBacks(offsets), 1);
    });

    testWidgets('a velocity change restarts the round at the new speed', (
      tester,
    ) async {
      await mount(tester, scroll(numberOfReps: 2));
      await sample(tester, second);
      await mount(
        tester,
        scroll(
          numberOfReps: 2,
          velocity: const Velocity(pixelsPerSecond: Offset(200, 0)),
        ),
      );
      await tester.pump();
      expect(offset(tester), 0);

      final offsets = await sample(tester, const Duration(seconds: 5));
      expect(offsets[10] - offsets[5], closeTo(50, 1));
      expect(jumpBacks(offsets), 2);
    });

    testWidgets(
      'rebuilds with equal arguments do not disturb the scroll (#38)',
      (tester) async {
        Future<List<double>> run({required bool rebuild}) async {
          final rebuilds = ValueNotifier(0);
          await mount(
            tester,
            ValueListenableBuilder<int>(
              valueListenable: rebuilds,
              builder: (context, _, _) => TextScroll(
                text,
                style: style.copyWith(),
                intervalSpaces: 6,
                velocity: Velocity(pixelsPerSecond: const Offset(60, 0)),
                pauseBetween: second,
                delayBefore: second,
              ),
            ),
          );
          final offsets = <double>[];
          for (var i = 0; i < 100; i++) {
            if (rebuild) rebuilds.value++;
            offsets.addAll(await sample(tester, tick));
          }
          await tester.pumpWidget(const SizedBox());
          return offsets;
        }

        final undisturbed = await run(rebuild: false);
        expect(maxOf(undisturbed), greaterThan(100));
        expect(await run(rebuild: true), undisturbed);
      },
    );
  });

  testWidgets('selectable text scrolls', (tester) async {
    await mount(tester, scroll(selectable: true));
    final offsets = await sample(tester, const Duration(seconds: 2));

    expect(maxOf(offsets), greaterThan(0));
  });

  testWidgets('changes do not notify scroll listeners during build', (
    tester,
  ) async {
    late StateSetter setInner;
    var content = text;
    var speed = velocity;
    await mount(
      tester,
      StatefulBuilder(
        builder: (context, setOuter) =>
            NotificationListener<ScrollNotification>(
              onNotification: (_) {
                setOuter(() {});
                return false;
              },
              child: StatefulBuilder(
                builder: (context, setState) {
                  setInner = setState;
                  return scroll(content: content, velocity: speed);
                },
              ),
            ),
      ),
    );
    await sample(tester, second);
    setInner(() => content = 'abcdefghijklmnopqrstuvwxyz');
    await sample(tester, second);
    setInner(() => speed = const Velocity(pixelsPerSecond: Offset(200, 0)));
    await sample(tester, second);
  });

  for (final (dx, issue) in [(0.0, ''), (-100.0, ' (#43)')]) {
    testWidgets('velocity $dx neither moves nor throws$issue', (tester) async {
      await mount(
        tester,
        scroll(velocity: Velocity(pixelsPerSecond: Offset(dx, 0))),
      );
      final offsets = await sample(tester, const Duration(seconds: 2));

      expect(offsets, everyElement(0));
    });
  }

  group('layout', () {
    testWidgets('waits for layout instead of throwing, then scrolls (#45)', (
      tester,
    ) async {
      final content = ValueNotifier(text);
      final cover = OverlayEntry(
        opaque: true,
        builder: (_) => const SizedBox(),
      );
      await mount(
        tester,
        Overlay(
          initialEntries: [
            OverlayEntry(
              maintainState: true,
              builder: (_) => ValueListenableBuilder<String>(
                valueListenable: content,
                builder: (_, value, _) => scroll(content: value),
              ),
            ),
            cover,
          ],
        ),
      );
      await tester.pump(second);
      content.value = 'abcdefghijklmnopqrstuvwxyz';
      await tester.pump(second);
      cover.remove();
      final offsets = await sample(tester, const Duration(seconds: 2));

      expect(maxOf(offsets), greaterThan(50));
    });

    testWidgets('a text change on a route never shown does not throw (#45)', (
      tester,
    ) async {
      final content = ValueNotifier(text);
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/details',
          routes: {
            '/': (_) => ValueListenableBuilder<String>(
              valueListenable: content,
              builder: (_, value, _) => scroll(content: value),
            ),
            '/details': (_) => const SizedBox(),
          },
        ),
      );
      await tester.pump(second);
      content.value = 'abcdefghijklmnopqrstuvwxyz';
      await tester.pump(second);
    });

    testWidgets('centered text stays centered on the frame its text changes', (
      tester,
    ) async {
      Future<void> mountCentered(String content) => mount(
        tester,
        TextScroll(content, style: style, textAlign: TextAlign.center),
      );
      await mountCentered('ABC');
      await sample(tester, second);
      await mountCentered('XYZ');

      expect(tester.getSize(find.text('XYZ')).width, 100);
    });

    testWidgets('an intrinsic column shrinks back after a sibling shrinks', (
      tester,
    ) async {
      final sibling = ValueNotifier('X');
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: ValueListenableBuilder<String>(
              valueListenable: sibling,
              builder: (_, value, _) => IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    scroll(content: 'ABC'),
                    Text(value, style: style),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      final widths = <double>[];
      for (final value in ['X', 'X' * 60, 'X']) {
        sibling.value = value;
        await sample(tester, second);
        widths.add(tester.getSize(find.byType(TextScroll)).width);
      }

      expect(widths, [30, 600, 30]);
    });
  });

  for (final (label, widget) in [
    ('text that fits', scroll(content: 'ABC', numberOfReps: 1)),
    (
      'zero velocity',
      scroll(
        numberOfReps: 1,
        velocity: const Velocity(pixelsPerSecond: Offset.zero),
      ),
    ),
    (
      'a velocity too fast to see',
      scroll(
        numberOfReps: 1,
        velocity: const Velocity(pixelsPerSecond: Offset(1000000, 0)),
      ),
    ),
    (
      'bouncing text that fits',
      scroll(content: 'ABC', mode: TextScrollMode.bouncing, numberOfReps: 2),
    ),
  ]) {
    testWidgets('numberOfReps stops the timer for $label', (tester) async {
      var ticks = 0;
      await runZoned(
        () => mount(tester, widget),
        zoneSpecification: ZoneSpecification(
          createPeriodicTimer: (self, parent, zone, period, tick) =>
              parent.createPeriodicTimer(zone, period, (timer) {
                ticks++;
                tick(timer);
              }),
        ),
      );
      await sample(tester, second);
      final settled = ticks;
      await sample(tester, const Duration(seconds: 5));

      expect(ticks, settled);
    });
  }

  group('dispose', () {
    testWidgets('unmounting mid-scroll leaves no timer running', (
      tester,
    ) async {
      await mount(tester, scroll());
      await sample(tester, second);
      await tester.pumpWidget(const SizedBox());
    });

    for (final (name, widget) in [
      ('delayBefore', scroll(delayBefore: const Duration(seconds: 10))),
      ('pauseBetween', scroll(pauseBetween: const Duration(seconds: 10))),
      (
        'pauseOnBounce',
        scroll(
          mode: TextScrollMode.bouncing,
          pauseOnBounce: const Duration(seconds: 10),
        ),
      ),
    ]) {
      testWidgets('unmounting during $name leaves no timer running', (
        tester,
      ) async {
        await mount(tester, widget);
        await sample(tester, const Duration(milliseconds: 2500));
        await tester.pumpWidget(const SizedBox());
      });
    }
  });
}
