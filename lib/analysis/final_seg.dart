
import 'package:flutter/services.dart';

import 'node.dart';
import 'pair.dart';
import '../conversion/common_conversion_definition.dart';

import 'character_utils.dart';

class FinalSeg {
  static FinalSeg? singleInstance;
  static const String PROB_EMIT = "packages/jieba_flutter/assets/prob_emit.txt";
  static List<String> states = ['B', 'M', 'E', 'S'];
  late Map<String, Map<String, double>> emit;
  late Map<String, double> start;
  late Map<String, Map<String, double>> trans;
  late Map<String, List<String>> prevStatus;
  static double MIN_FLOAT = -3.14e100;

  FinalSeg();

  static Future<FinalSeg> getInstance() async {
    if (null == singleInstance) {
      singleInstance = FinalSeg();
      await singleInstance?.loadModel();
    }
    return singleInstance!;
  }

  Future<void> loadModel() async {
    prevStatus = {};
    prevStatus.put('B', ['E', 'S']);
    prevStatus.put('M', ['M', 'B']);
    prevStatus.put('S', ['S', 'E']);
    prevStatus.put('E', ['B', 'M']);

    start = {};
    start.put('B', -0.26268660809250016);
    start.put('E', -3.14e+100);
    start.put('M', -3.14e+100);
    start.put('S', -1.4652633398537678);

    trans = {};
    Map<String, double> transB = {};
    transB.put('E', -0.510825623765990);
    transB.put('M', -0.916290731874155);
    trans.put('B', transB);
    Map<String, double> transE = {};
    transE.put('B', -0.5897149736854513);
    transE.put('S', -0.8085250474669937);
    trans.put('E', transE);
    Map<String, double> transM = {};
    transM.put('E', -0.33344856811948514);
    transM.put('M', -1.2603623820268226);
    trans.put('M', transM);
    Map<String, double> transS = {};
    transS.put('B', -0.7211965654669841);
    transS.put('S', -0.6658631448798212);
    trans.put('S', transS);

    var file = await rootBundle.loadString(PROB_EMIT);

    emit = {};
    Map<String, double> values = {};
    for (var line in file.split("\n")) {
      List<String> tokens = line.split("\t");
      if (tokens.length == 1) {
        values = {};
        if (tokens[0].isNotEmpty) emit.put(tokens[0].charAt(0), values);
      } else {
        values.put(tokens[0].charAt(0), double.parse(tokens[1]));
      }
    }
  }

  void cut(String sentence, List<String> tokens) {
    StringBuffer chinese = StringBuffer();
    StringBuffer other = StringBuffer();
    for (int i = 0; i < sentence.length; ++i) {
      String ch = sentence[i];
      if (CharacterUtil.isChineseLetter(ch)) {
        if (other.isNotEmpty) {
          processOtherUnknownWords(other.toString(), tokens);
          other.clear();
        }
        chinese.write(ch);
      } else {
        if (chinese.isNotEmpty) {
          viterbi(chinese.toString(), tokens);
          chinese.clear();
        }
        other.write(ch);
      }
    }
    if (chinese.isNotEmpty) {
      viterbi(chinese.toString(), tokens);
    } else {
      processOtherUnknownWords(other.toString(), tokens);
    }
  }

  void viterbi(String sentence, List<String> tokens) {
    List<Map<String, double>> v = [];
    Map<String, Node> path = {};

    v.add({});
    for (String state in states) {
      double? emP = emit.get(state)?.get(sentence[0]);
      emP ??= MIN_FLOAT;
      v[0].put(state, start.get(state)! + emP);
      path.put(state, Node(state, null));
    }

    for (int i = 1; i < sentence.length; ++i) {
      Map<String, double> vv = {};
      v.add(vv);
      Map<String, Node> newPath = {};
      for (String y in states) {
        double? emp = emit.get(y)?.get(sentence.charAt(i));
        emp ??= MIN_FLOAT;
        Pair<String>? candidate;
        for (String y0 in prevStatus.get(y)!) {
          double? tranp = trans.get(y0)?.get(y);
          tranp ??= MIN_FLOAT;
          tranp += (emp + v[i - 1].get(y0)!);
          if (null == candidate) {
            candidate = Pair<String>(y0, tranp);
          } else if (candidate.freq <= tranp) {
            candidate.freq = tranp;
            candidate.key = y0;
          }
        }
        vv.put(y, candidate!.freq);
        newPath.put(y, Node(y, path.get(candidate.key)));
      }
      path = newPath;
    }
    double probE = v[sentence.length - 1].get('E')!;
    double probS = v[sentence.length - 1].get('S')!;
    List<String> posList = [];
    Node? win;
    if (probE < probS) {
      win = path.get('S')!;
    } else {
      win = path.get('E')!;
    }

    while (win != null) {
      posList.add(win.value);
      win = win.parent;
    }
    posList = posList.reversed.toList();

    int begin = 0, next = 0;
    for (int i = 0; i < sentence.length; ++i) {
      String pos = posList[i];
      if (pos == 'B') {
        begin = i;
      } else if (pos == 'E') {
        tokens.add(sentence.substring(begin, i + 1));
        next = i + 1;
      } else if (pos == 'S') {
        tokens.add(sentence.substring(i, i + 1));
        next = i + 1;
      }
    }
    if (next < sentence.length) {
      tokens.add(sentence.substring(next));
    }
  }

  void processOtherUnknownWords(String other, List<String> tokens) {
    var mat = CharacterUtil.reSkip.allMatches(other);
    int offset = 0;
    for (var match in mat) {
      if (match.start > offset) {
        tokens.add(other.substring(offset, match.start));
      }
      tokens.add(match.group(0)!);
      offset = match.end;
    }
    if (offset < other.length) {
      tokens.add(other.substring(offset));
    }
  }
}
