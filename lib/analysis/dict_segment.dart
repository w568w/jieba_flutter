import 'dart:core';
import 'package:jieba_flutter/convertion/common_convertion_defination.dart';

import 'hit.dart';

/// 词典树分段，表示词典树的一个分枝
class DictSegment implements Comparable<DictSegment> {
  // 公用字典表，存储汉字
  static Map<String, String> charMap = {};

  // 数组大小上限
  static const int ARRAY_LENGTH_LIMIT = 3;

  // Map存储结构
  Map<String, DictSegment>? childrenMap;

  // 数组方式存储结构
  List<DictSegment>? childrenArray;

  // 当前节点上存储的字符
  String nodeChar;

  // 当前节点存储的Segment数目
  // storeSize <=ARRAY_LENGTH_LIMIT ，使用数组存储， storeSize >ARRAY_LENGTH_LIMIT
  // ,则使用Map存储
  int storeSize = 0;

  // 当前DictSegment状态 ,默认 0 , 1表示从根节点到当前节点的路径表示一个词
  int nodeState = 0;

  DictSegment(this.nodeChar);

  String getNodeChar() {
    return nodeChar;
  }

  /*
     * 判断是否有下一个节点
     */
  bool hasNextNode() {
    return storeSize > 0;
  }

  /// 匹配词段
  ///
  /// @param charArray
  /// @param begin
  /// @param length
  /// @param searchHit
  /// @return Hit
  Hit match(List<String> charArray,
      [int begin = 0, int? length, Hit? searchHit]) {
    length ??= charArray.length;
    if (searchHit == null) {
      // 如果hit为空，新建
      searchHit = Hit();
      // 设置hit的其实文本位置
      searchHit.setBegin(begin);
    } else {
      // 否则要将HIT状态重置
      searchHit.setUnmatch();
    }
    // 设置hit的当前处理位置
    searchHit.setEnd(begin);

    String keyChar = charArray[begin];
    DictSegment? ds;

    // 引用实例变量为本地变量，避免查询时遇到更新的同步问题
    List<DictSegment>? segmentArray = childrenArray;
    Map<String, DictSegment>? segmentMap = childrenMap;

    // STEP1 在节点中查找keyChar对应的DictSegment
    if (segmentArray != null) {
      // 在数组中查找
      DictSegment keySegment = DictSegment(keyChar);
      int position =
          binarySearch(segmentArray, keySegment, start: 0, end: storeSize);
      if (position >= 0) {
        ds = segmentArray[position];
      }
    } else if (segmentMap != null) {
      // 在map中查找
      ds = segmentMap[keyChar];
    }

    // STEP2 找到DictSegment，判断词的匹配状态，是否继续递归，还是返回结果
    if (ds != null) {
      if (length > 1) {
        // 词未匹配完，继续往下搜索
        return ds.match(charArray, begin + 1, length - 1, searchHit);
      } else if (length == 1) {
        // 搜索最后一个char
        if (ds.nodeState == 1) {
          // 添加HIT状态为完全匹配
          searchHit.setMatch();
        }
        if (ds.hasNextNode()) {
          // 添加HIT状态为前缀匹配
          searchHit.setPrefix();
          // 记录当前位置的DictSegment
          searchHit.setMatchedDictSegment(ds);
        }
        return searchHit;
      }
    }
    // STEP3 没有找到DictSegment， 将HIT设置为不匹配
    return searchHit;
  }

  /// 屏蔽词典中的一个词
  ///
  /// @param charArray
  void disableSegment(List<String> charArray) {
    fillSegment(charArray, 0, charArray.length, 0);
  }

  /// 加载填充词典片段
  ///
  /// @param charArray
  /// @param begin
  /// @param length
  /// @param enabled

  void fillSegment(List<String> charArray,
      [int begin = 0, int? length, int enabled = 1]) {
    length ??= charArray.length;
    // 获取字典表中的汉字对象
    String beginChar = charArray[begin];
    String? keyChar = charMap[beginChar];
    // 字典中没有该字，则将其添加入字典
    if (keyChar == null) {
      charMap[beginChar] = beginChar;
      keyChar = beginChar;
    }

    // 搜索当前节点的存储，查询对应keyChar的keyChar，如果没有则创建
    DictSegment? ds = lookforSegment(keyChar, enabled);
    if (length > 1) {
      // 词元还没有完全加入词典树
      ds!.fillSegment(charArray, begin + 1, length - 1, enabled);
    } else if (length == 1) {
      // 已经是词元的最后一个char,设置当前节点状态为enabled，
      // enabled=1表明一个完整的词，enabled=0表示从词典中屏蔽当前词
      ds!.nodeState = enabled;
    }
  }

  /// 查找本节点下对应的keyChar的segment *
  ///
  /// @param keyChar
  /// @param create
  ///            =1如果没有找到，则创建新的segment ; =0如果没有找到，不创建，返回null
  /// @return
  DictSegment? lookforSegment(String keyChar, int create) {
    DictSegment? ds;

    if (storeSize <= ARRAY_LENGTH_LIMIT) {
      // 获取数组容器，如果数组未创建则创建数组
      List<DictSegment> segmentArray = getChildrenArray();
      // 搜寻数组
      DictSegment keySegment = DictSegment(keyChar);
      int position =
          binarySearch(segmentArray, keySegment, start: 0, end: storeSize);
      if (position >= 0) {
        ds = segmentArray[position];
      }

      // 遍历数组后没有找到对应的segment
      if (ds == null && create == 1) {
        ds = keySegment;
        if (storeSize < ARRAY_LENGTH_LIMIT) {
          // 数组容量未满，使用数组存储
          segmentArray[storeSize] = ds;
          // segment数目+1
          storeSize++;

          mergeSort(segmentArray, start: 0, end: storeSize);
        } else {
          // 数组容量已满，切换Map存储
          // 获取Map容器，如果Map未创建,则创建Map
          Map<String, DictSegment> segmentMap = getChildrenMap();
          // 将数组中的segment迁移到Map中
          migrate(segmentArray, segmentMap);
          // 存储新的segment
          segmentMap[keyChar] = ds;
          // segment数目+1 ， 必须在释放数组前执行storeSize++ ， 确保极端情况下，不会取到空的数组
          storeSize++;
          // 释放当前的数组引用
          childrenArray = null;
        }
      }
    } else {
      // 获取Map容器，如果Map未创建,则创建Map
      Map<String, DictSegment> segmentMap = getChildrenMap();
      // 搜索Map
      ds = segmentMap[keyChar];
      if (ds == null && create == 1) {
        // 构造新的segment
        ds = DictSegment(keyChar);
        segmentMap[keyChar] = ds;
        // 当前节点存储segment数目+1
        storeSize++;
      }
    }

    return ds;
  }

  /// 获取数组容器 线程同步方法
  List<DictSegment> getChildrenArray() {
    childrenArray ??= [];
    return childrenArray!;
  }

  /// 获取Map容器 线程同步方法
  Map<String, DictSegment> getChildrenMap() {
    childrenMap ??= {};
    return childrenMap!;
  }

  /// 将数组中的segment迁移到Map中
  ///
  /// @param segmentArray

  void migrate(
      List<DictSegment> segmentArray, Map<String, DictSegment> segmentMap) {
    for (DictSegment segment in segmentArray) {
      segmentMap[segment.nodeChar] = segment;
    }
  }

  /// 实现Comparable接口
  ///
  /// @param o
  /// @return int
  @override
  int compareTo(DictSegment o) {
    // 对当前节点存储的char进行比较
    return nodeChar.compareTo(o.nodeChar);
  }
}
