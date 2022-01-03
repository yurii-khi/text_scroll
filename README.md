# text_scroller

`TextScroller` Flutter widget adds text auto-scrolling functionality (marquee text).

## Features

 - `endless` and `bouncing` modes
 - delay and pause between rounds
 - max number of rounds
 - custom velocity
 - `style` and `textAlign` support

## Getting started

To use this plugin, add text_scroller as a dependency in your pubspec.yaml file.

## Usage

Minimal example:

```dart
    TextScroller('This is the sample text for Flutter TextScroller widget. ')
```

Custom settings:

```dart
    TextScroller(
        'This is the sample text for Flutter TextScroller widget. ',
        mode: TextScrollerMode.bouncing,
        velocity: Velocity(pixelsPerSecond: Offset(150, 0)),
        delayBefore: Duration(milliseconds: 500),
        numberOfReps: 5,
        pauseBetween: Duration(milliseconds: 50),
        style: TextStyle(color: Colors.green),
        textAlign: TextAlign.right,
    )
```
