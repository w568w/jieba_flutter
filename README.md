## Features

A Flutter implementation of Chinese word segmentation Python library, [jieba](https://github.com/fxsjy/jieba).

This library is essentially a line-by-line translation of the Java implementation of jieba, [jieba-analysis](https://github.com/huaban/jieba-analysis/).
## Usage

```dart
await JiebaSegmenter.init();
final seg = JiebaSegmenter();
print(seg.process("结过婚和尚未结过婚的", SegMode.SEARCH))

/// Output: [[结过, 0, 2], [婚, 2, 3], [和, 3, 4], [尚未, 4, 6], [结过, 6, 8], [婚, 8, 9], [的, 9, 10]]
```

## Licenses

This project is dual-licensed under [the GNU General Public License v3.0](LICENSE-GPL) and [the Apache License 2.0](LICENSE-APACHE) (since version 0.2.0).

We encourage you to use GPLv3.0 for your open-source projects. But if you want to use this library in a commercial project, please conform to the Apache License 2.0 at least.