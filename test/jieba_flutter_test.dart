import 'package:flutter_test/flutter_test.dart';
import 'package:jieba_flutter/analysis/jieba_segmenter.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });
  test('adds one to input values', () async {
    await JiebaSegmenter.init().then((value) {
      var seg = JiebaSegmenter();
      print(
          seg.process("结过婚和尚未结过婚的", SegMode.SEARCH));
    });
  });
}
