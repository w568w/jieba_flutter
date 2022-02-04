import 'pair.dart';
import 'seg_token.dart';
import 'word_dict.dart';
import '../convertion/common_convertion_defination.dart';

import 'character_utils.dart';
import 'dict_segment.dart';
import 'final_seg.dart';
import 'hit.dart';

enum SegMode { INDEX, SEARCH }

class JiebaSegmenter {
  static WordDictionary? wordDict;
  static FinalSeg? finalSeg;
  static Future<void>  init() async{
    wordDict = await WordDictionary.getInstance();
    finalSeg = await FinalSeg.getInstance();
  }
  /// initialize the user dictionary.
  ///
  /// @param path user dict dir
  void initUserDict(String path) {
    wordDict?.init(path);
  }

  void initUserDicts(List<String> paths) {
    wordDict?.inits(paths);
  }

  Map<int, List<int>> createDAG(String sentence) {
    Map<int, List<int>> dag = {};
    DictSegment trie = wordDict!.getTrie();
    List<String> chars = sentence.charArray;
    int N = chars.length;
    int i = 0, j = 0;
    while (i < N) {
      Hit hit = trie.match(chars, i, j - i + 1);
      if (hit.isPrefix() || hit.isMatch()) {
        if (hit.isMatch()) {
          if (!dag.containsKey(i)) {
            List<int> value = [];
            dag[i] = value;
            value.add(j);
          } else {
            dag[i]?.add(j);
          }
        }
        j += 1;
        if (j >= N) {
          i += 1;
          j = i;
        }
      } else {
        i += 1;
        j = i;
      }
    }
    for (i = 0; i < N; ++i) {
      if (!dag.containsKey(i)) {
        List<int> value = [];
        value.add(i);
        dag.put(i, value);
      }
    }
    return dag;
  }

  Map<int, Pair<int>> calc(String sentence, Map<int, List<int>> dag) {
    int N = sentence.length;
    Map<int, Pair<int>> route = {};
    route[N] = Pair<int>(0, 0.0);
    for (int i = N - 1; i > -1; i--) {
      Pair<int>? candidate;
      for (int x in dag[i]!) {
        double freq =
            wordDict!.getFreq(sentence.substring(i, x + 1)) + route[x + 1]!.freq;
        if (null == candidate) {
          candidate = Pair<int>(x, freq);
        } else if (candidate.freq < freq) {
          candidate.freq = freq;
          candidate.key = x;
        }
      }
      route[i] = candidate!;
    }
    return route;
  }

  List<SegToken> process(String paragraph, SegMode mode) {
    List<SegToken> tokens = [];
    StringBuffer sb = StringBuffer();
    int offset = 0;
    for (int i = 0; i < paragraph.length; ++i) {
      String ch = CharacterUtil.regularize(paragraph.charAt(i));
      if (CharacterUtil.ccFind(ch)) {
        sb.write(ch);
      } else {
        if (sb.isNotEmpty) {
          // process
          if (mode == SegMode.SEARCH) {
            for (String word in sentenceProcess(sb.toString())) {
              tokens.add(SegToken(word, offset, offset += word.length));
            }
          } else {
            for (String token in sentenceProcess(sb.toString())) {
              if (token.length > 2) {
                String gram2;
                int j = 0;
                for (; j < token.length - 1; ++j) {
                  gram2 = token.substring(j, j + 2);
                  if (wordDict!.containsWord(gram2)) {
                    tokens.add(SegToken(gram2, offset + j, offset + j + 2));
                  }
                }
              }
              if (token.length > 3) {
                String gram3;
                int j = 0;
                for (; j < token.length - 2; ++j) {
                  gram3 = token.substring(j, j + 3);
                  if (wordDict!.containsWord(gram3)) {
                    tokens.add(SegToken(gram3, offset + j, offset + j + 3));
                  }
                }
              }
              tokens.add(SegToken(token, offset, offset += token.length));
            }
          }
          sb.clear();
          offset = i;
        }
        if (wordDict!.containsWord(paragraph.substring(i, i + 1))) {
          tokens.add(SegToken(paragraph.substring(i, i + 1), offset, ++offset));
        } else {
          tokens.add(SegToken(paragraph.substring(i, i + 1), offset, ++offset));
        }
      }
    }
    if (sb.isNotEmpty) {
      if (mode == SegMode.SEARCH) {
        for (String token in sentenceProcess(sb.toString())) {
          tokens.add(SegToken(token, offset, offset += token.length));
        }
      } else {
        for (String token in sentenceProcess(sb.toString())) {
          if (token.length > 2) {
            String gram2;
            int j = 0;
            for (; j < token.length - 1; ++j) {
              gram2 = token.substring(j, j + 2);
              if (wordDict!.containsWord(gram2)) {
                tokens.add(SegToken(gram2, offset + j, offset + j + 2));
              }
            }
          }
          if (token.length > 3) {
            String gram3;
            int j = 0;
            for (; j < token.length - 2; ++j) {
              gram3 = token.substring(j, j + 3);
              if (wordDict!.containsWord(gram3)) {
                tokens.add(SegToken(gram3, offset + j, offset + j + 3));
              }
            }
          }
          tokens.add(SegToken(token, offset, offset += token.length));
        }
      }
    }

    return tokens;
  }

/*
     *
     */
  List<String> sentenceProcess(String sentence) {
    List<String> tokens = [];
    int N = sentence.length;
    Map<int, List<int>> dag = createDAG(sentence);
    Map<int, Pair<int>> route = calc(sentence, dag);

    int x = 0;
    int y = 0;
    String buf;
    StringBuffer sb = StringBuffer();
    while (x < N) {
      y = route.get(x)!.key + 1;
      String lWord = sentence.substring(x, y);
      if (y - x == 1) {
        sb.write(lWord);
      } else {
        if (sb.isNotEmpty) {
          buf = sb.toString();
          sb.clear();
          if (buf.length == 1) {
            tokens.add(buf);
          } else {
            if (wordDict!.containsWord(buf)) {
              tokens.add(buf);
            } else {
              finalSeg!.cut(buf, tokens);
            }
          }
        }
        tokens.add(lWord);
      }
      x = y;
    }
    buf = sb.toString();
    if (buf.isNotEmpty) {
      if (buf.length == 1) {
        tokens.add(buf);
      } else {
        if (wordDict!.containsWord(buf)) {
          tokens.add(buf);
        } else {
          finalSeg!.cut(buf, tokens);
        }
      }
    }
    return tokens;
  }
}
