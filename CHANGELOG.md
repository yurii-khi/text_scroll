## 0.3.0
* require Dart 3.11 and Flutter 3.41
* fix a null check crash when the widget is not laid out yet (#45)
* fix the `duration > Duration.zero` assertion: a negative velocity now stands still, like zero (#43)
* restart when `text` changes, in bouncing mode too (#44)
* restart when `mode`, `intervalSpaces` or a layout-changing `style` changes
* count `numberOfReps` in full rounds: in endless mode `numberOfReps: n` now scrolls n rounds, not n - 1
* restart at the new speed when `velocity` changes, in bouncing mode too and with `numberOfReps` set
* count `numberOfReps` from zero after a restart, so a change scrolls again once the rounds ran out
* cancel pending `delayBefore`, `pauseBetween` and `pauseOnBounce` timers on dispose
* stop throwing `setState() or markNeedsBuild() called during build` in an ancestor scroll listener when the text changes

## 0.2.1
* bug fixes and improvements

## 0.2.0
* added support for dynamically updating widget parameters, enabling users to control scrolling behavior from parent widgets
* added border fade effect
* added bouncing mode animation pause at end of text
* bug fixes and improvements

## 0.1.2
* bug fixes

## 0.1.1
* allow `pauseBetween` in `TextScrollMode.endless` mode

## 0.1.0
* add `intervalSpaces` property for `TextScrollMode.endless`
* bug fixes

## 0.0.5
* tidy up static analysis warnings after Flutter upgrade to 3.0.2

## 0.0.4
* introduce `textDirection` property

## 0.0.3
* update docs
* add `selectable` property

## 0.0.2
* fix flex behavior
* update docs

## 0.0.1

### Initial release
* endless and bouncing auto-scrolling
* velocity
* delay
* pause
* max repetitions number
* style
* text alignment