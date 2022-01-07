# text_scroll

`TextScroll` Flutter widget adds text auto-scrolling functionality (marquee text).

![demo](https://user-images.githubusercontent.com/29194552/148517560-6f41a081-9b34-4975-9052-a2855d46b555.gif)

## Features

 - `endless` and `bouncing` modes
 - delay and pause between rounds
 - max number of rounds
 - custom velocity
 - `style` and `textAlign` support

## Getting started

To use this package, add text_scroll as a dependency in your pubspec.yaml file.

## Usage

Minimal example:

```dart
    TextScroll('This is the sample text for Flutter TextScroll widget. ')
```

Custom settings:

```dart
    TextScroll(
        'This is the sample text for Flutter TextScroll widget. ',
        mode: TextScrollMode.bouncing,
        velocity: Velocity(pixelsPerSecond: Offset(150, 0)),
        delayBefore: Duration(milliseconds: 500),
        numberOfReps: 5,
        pauseBetween: Duration(milliseconds: 50),
        style: TextStyle(color: Colors.green),
        textAlign: TextAlign.right,
        selectable: true,
    )
```

## See also

 - [github repo](https://github.com/yurii-khi/text_scroll)
 - [pub.dev package](https://pub.dev/packages/text_scroll)
 - [api reference](https://pub.dev/documentation/text_scroll/latest/text_scroll/TextScroll-class.html)
