import '../convertion/common_convertion_defination.dart';

class CharacterUtil {
  static RegExp reSkip = RegExp("(\\d+\\.\\d+|[a-zA-Z0-9]+)");
  static final List<String> connectors = ['+', '#', '&', '.', '_', '-'];

  static bool isChineseLetter(String ch) {
    if (ch.charCode >= 0x4E00 && ch.charCode <= 0x9FA5) return true;
    return false;
  }

  static bool isEnglishLetter(String ch) {
    if ((ch.charCode >= 0x0041 && ch.charCode <= 0x005A) || (ch.charCode >= 0x0061 && ch.charCode <= 0x007A)) {
      return true;
    }
    return false;
  }

  static bool isDigit(String ch) {
    int charCode = ch.charCode;
    if (charCode >= 0x0030 && charCode <= 0x0039) return true;
    return false;
  }

  static bool isConnector(String ch) {
    for (String connector in connectors) {
      if (ch == connector) return true;
    }
    return false;
  }

  static bool ccFind(String ch) {
    if (isChineseLetter(ch)) {
      return true;
    }
    if (isEnglishLetter(ch)) return true;
    if (isDigit(ch)) return true;
    if (isConnector(ch)) return true;
    return false;
  }

  /// 全角 to 半角,大写 to 小写
  ///
  /// @param input
  ///            输入字符
  /// @return 转换后的字符

  static String regularize(String input) {
    int charCode = input.runes.first;
    if (charCode == 12288) {
      return String.fromCharCode(32);
    } else if (charCode > 65280 && charCode < 65375) {
      return String.fromCharCode(charCode - 65248);
    } else if (charCode >= 'A'.runes.first && charCode <= 'Z'.runes.first) {
      return String.fromCharCode(charCode += 32);
    }
    return input;
  }
}
