import 'dart:collection';
import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';

import '../conversion/common_conversion_definition.dart';

import 'dict_segment.dart';

class WordDictionary {
  static WordDictionary? singleton;
  static const String MAIN_DICT = "assets/dict.txt";
  static const String USER_DICT_SUFFIX = ".dict";

  final Map<String, double> freqs = {};
  final Set<String> loadedPath = HashSet<String>();
  double minFreq = double.maxFinite;
  double total = 0.0;
  late DictSegment _dict;

  WordDictionary();

  static Future<WordDictionary> getInstance() async {
    if (singleton == null) {
      singleton = WordDictionary();
      await singleton?.loadDict();
      return singleton!;
    }
    return singleton!;
  }

  /// for ES to initialize the user dictionary.
  ///
  /// @param configFile
  void init(String configFile) {
    var dir = Directory(configFile);
    String abspath = File(configFile).absolute.path;
    if (loadedPath.contains(abspath)) {
      return;
    }
    for (var path in dir.listSync()) {
      if (path.path.endsWith(USER_DICT_SUFFIX)) {
        singleton?.loadUserDict(path.path);
      }
    }
    loadedPath.add(abspath);
  }

  void inits(List<String> paths) {
    for (String path in paths) {
      if (!loadedPath.contains(path)) {
        try {
          singleton?.loadUserDict(path);
          loadedPath.add(path);
        } on Exception catch (_) {
          // TODO Auto-generated catch block
        }
      }
    }
  }

  /// let user just use their own dict instead of the default dict
  void resetDict() {
    _dict = DictSegment('');
    freqs.clear();
  }

  Future<void> loadDict() async {
    _dict = DictSegment('');
    var file = await rootBundle.loadString(MAIN_DICT);
    for (var line in file.split("\n")) {
      List<String> tokens = line.split(RegExp(r'[\t ]+'));

      if (tokens.length < 2) {
        continue;
      }

      String word = tokens[0];
      double freq = double.parse(tokens[1]);
      total += freq;
      word = addWord(word)!;
      freqs[word] = freq;
    }
    // normalize
    freqs.forEach((key, value) {
      freqs[key] = log(value / total);
      minFreq = min(value, minFreq);
    });
  }

  String? addWord(String word) {
    if (word.trim().isNotEmpty) {
      String key = word.trim().toLowerCase();
      _dict.fillSegment(key.charArray);
      return key;
    } else {
      return null;
    }
  }

  void loadUserDict(String userDictPath) {
    var file = File(userDictPath);

    List<String> lines = file.readAsLinesSync();
    for (var line in lines) {
      List<String> tokens = line.split(RegExp(r'[\t ]+'));

      if (tokens.isEmpty) {
        // Ignore empty line
        continue;
      }

      String word = tokens[0];

      double freq = 3.0;
      if (tokens.length == 2) {
        freq = double.parse(tokens[1]);
      }
      final addedWord = addWord(word);
      if (addedWord == null) {
        continue;
      }
      freqs[addedWord] = log(freq / total);
    }
  }

  DictSegment getTrie() {
    return _dict;
  }

  bool containsWord(String word) {
    return freqs.containsKey(word);
  }

  double getFreq(String key) {
    if (containsWord(key)) {
      return freqs[key]!;
    } else {
      return minFreq;
    }
  }
}
