import 'dart:io';
import 'dart:ui' as ui;

import 'package:example/main.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:text_scroll/text_scroll.dart';

const size = Size(420, 330);
const frameInterval = Duration(milliseconds: 100);
const frameCount = 70;
const tapAtFrame = 20;
const output = '../doc/demo.gif';

Future<void> loadRoboto() {
  final font = File(
    '${Platform.environment['FLUTTER_ROOT']}/bin/cache/artifacts/material_fonts/Roboto-Regular.ttf',
  );
  return (FontLoader(
    'Roboto',
  )..addFont(font.readAsBytes().then(ByteData.sublistView))).load();
}

Future<img.Image> capture(WidgetTester tester, GlobalKey boundary) async {
  final render =
      boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final frame = await tester.runAsync(() async {
    final image = await render.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    return img.Image.fromBytes(
      width: image.width,
      height: image.height,
      bytes: bytes!.buffer,
      numChannels: 4,
    );
  });
  return frame!;
}

void main() {
  testWidgets('render the README demo', (tester) async {
    await tester.runAsync(loadRoboto);
    WidgetsApp.debugAllowBannerOverride = false;
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final boundary = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(key: boundary, child: const MyApp()),
    );

    final encoder = img.GifEncoder(
      repeat: 0,
      delay: frameInterval.inMilliseconds ~/ 10,
      numColors: 16,
      quantizerType: img.QuantizerType.octree,
      dither: img.DitherKernel.none,
    );
    for (var i = 0; i < frameCount; i++) {
      if (i == tapAtFrame) await tester.tap(find.byType(TextScroll).last);
      await tester.pump(frameInterval);
      encoder.addFrame(await capture(tester, boundary));
    }
    File(output).writeAsBytesSync(encoder.finish()!);
  });
}
