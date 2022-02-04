<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->


## Features

A Flutter implementation of Chinese word segmentation Python library, [jieba](https://github.com/fxsjy/jieba).

## Usage

```dart
await JiebaSegmenter.init().then((value) {
      var seg = JiebaSegmenter();
      print(
          seg.process("结过婚和尚未结过婚的", SegMode.SEARCH));
    });

/// Output: [[结过, 0, 2], [婚, 2, 3], [和, 3, 4], [尚未, 4, 6], [结过, 6, 8], [婚, 8, 9], [的, 9, 10]]
```

## Additional information
