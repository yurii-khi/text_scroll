#!/bin/sh
# Regenerates doc/demo.gif from the example app. Set FLUTTER="fvm flutter" to use the pinned SDK.
set -e
cd "$(dirname "$0")/../example"
${FLUTTER:-flutter} test tool/readme_gif_test.dart
