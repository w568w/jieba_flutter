///
/// IK 中文分词  版本 5.0
/// IK Analyzer release 5.0
///
/// Licensed to the Apache Software Foundation (ASF) under one or more
/// contributor license agreements.  See the NOTICE file distributed with
/// this work for additional information regarding copyright ownership.
/// The ASF licenses this file to You under the Apache License, Version 2.0
/// (the "License"); you may not use this file except in compliance with
/// the License.  You may obtain a copy of the License at
///
///     http://www.apache.org/licenses/LICENSE-2.0
///
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// limitations under the License.
///
/// 源代码由林良益(linliangyi2005@gmail.com)提供
/// 版权声明 2012，乌龙茶工作室
/// provided by Linliangyi and copyright 2012 by Oolong studio
///

import 'dict_segment.dart';

/// 表示一次词典匹配的命中
class Hit {
  //Hit不匹配
  static const int UNMATCH = 0x00000000;

  //Hit完全匹配
  static const int MATCH = 0x00000001;

  //Hit前缀匹配
  static const int PREFIX = 0x00000010;

  //该HIT当前状态，默认未匹配
  int hitState = UNMATCH;

  //记录词典匹配过程中，当前匹配到的词典分支节点
  DictSegment? matchedDictSegment;

  /*
	 * 词段开始位置
	 */
  int? begin;

  /*
	 * 词段的结束位置
	 */
  int? end;

  /// 判断是否完全匹配
  bool isMatch() {
    return (hitState & MATCH) > 0;
  }

  ///
  void setMatch() {
    hitState = hitState | MATCH;
  }

  /// 判断是否是词的前缀
  bool isPrefix() {
    return (hitState & PREFIX) > 0;
  }

  ///
  void setPrefix() {
    hitState = hitState | PREFIX;
  }

  /// 判断是否是不匹配
  bool isUnmatch() {
    return hitState == UNMATCH;
  }

  ///
  void setUnmatch() {
    hitState = UNMATCH;
  }

  DictSegment? getMatchedDictSegment() {
    return matchedDictSegment;
  }

  void setMatchedDictSegment(DictSegment matchedDictSegment) {
    this.matchedDictSegment = matchedDictSegment;
  }

  int? getBegin() {
    return begin;
  }

  void setBegin(int begin) {
    this.begin = begin;
  }

  int? getEnd() {
    return end;
  }

  void setEnd(int end) {
    this.end = end;
  }
}
