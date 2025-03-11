## Features

A Flutter implementation of Chinese word segmentation Python library, [jieba](https://github.com/fxsjy/jieba).

## Usage

```dart
await JiebaSegmenter.init();
final seg = JiebaSegmenter();
print(seg.process("结过婚和尚未结过婚的", SegMode.SEARCH))

/// Output: [[结过, 0, 2], [婚, 2, 3], [和, 3, 4], [尚未, 4, 6], [结过, 6, 8], [婚, 8, 9], [的, 9, 10]]
```