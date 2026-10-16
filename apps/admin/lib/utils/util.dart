import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

class Util {
  static String str(String text) {
    return text.replaceAll("-", "");
  }

  static String hideText(String text, {int size = 4}) {
    if (text.isEmpty) return "";
    if (text.length < size) size = (text.length / 2).ceil();
    int start = ((text.length - size) / 2).ceil();
    for (var i = start + 1; i <= start + size; i++) {
      text = text.replaceRange(i - 1, i, "X");
    }
    return text;
  }

  static String hideTextStart(String text, {int size = 4}) {
    if (text.isEmpty) return "";
    if (text.length < size) size = (text.length / 2).ceil();
    int start = 0;
    for (var i = start + 1; i <= start + size; i++) {
      text = text.replaceRange(i - 1, i, "X");
    }
    return text;
  }

  static String idcard(String text) {
    if (text.isEmpty) return "";
    if (text.length != 13) return text;
    String txt = "";
    txt += "${text.substring(0, 1)}-";
    txt += "${text.substring(1, 5)}-";
    txt += "${text.substring(5, 10)}-";
    txt += "${text.substring(10, 12)}-";
    txt += text.substring(12);
    return txt;
  }

  static String digitsOnly(String text) {
    return text.replaceAll(RegExp(r'\D'), '');
  }

  /// เลขบัตรประชาชน 13 หลัก ตาม checksum ของกรมการปกครอง
  static bool isValidIdCard(String text) {
    final id = digitsOnly(text);
    if (id.length != 13) return false;
    if (id.startsWith('0')) return false;

    var sum = 0;
    for (var i = 0; i < 12; i++) {
      sum += int.parse(id[i]) * (13 - i);
    }
    final checkDigit = (11 - (sum % 11)) % 10;
    return checkDigit == int.parse(id[12]);
  }

  static bool looksLikeIdCard(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;
    if (!RegExp(r'^[\d\s-]+$').hasMatch(trimmed)) return false;
    return digitsOnly(trimmed).length == 13;
  }

  static String mobile(String text) {
    if (text.isEmpty) return "";
    if (text.length != 10) return text;
    String txt = "";
    txt += "${text.substring(0, 3)}-";
    txt += "${text.substring(3, 6)}-";
    txt += text.substring(6);
    return txt;
  }

  static Object imageBase64(String? text) {
    if (text == null || text.isEmpty) return "";
    List<String> arr = text.split(",");
    if (arr.length != 2) return "";
    return base64.decode(arr[1]);
  }

  static double maxWidth(BuildContext context) {
    if (MediaQuery.of(context).size.width > 640) return 640.0;
    return MediaQuery.of(context).size.width;
  }

  static double maxWidthPadding(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width > 640) return (width - 640.0) / 2 < 0 ? 0 : (width - 640.0) / 2;
    return 0;
  }

  static double textScaleFactor(
    BuildContext context, {
    double maxTextScaleFactor = 2,
  }) {
    try {
      final width = MediaQuery.sizeOf(context).width;

      if (width > 640) {
        final val = (width / 1200) * maxTextScaleFactor;
        return min(val, maxTextScaleFactor);
      } else {
        final val = (width / 860) * maxTextScaleFactor;
        return min(val, maxTextScaleFactor);
      }
    } catch (_) {
      return 1;
    }
  }

  static Color string2HexColor(String hexString) {
    Color color = Color(int.parse(hexString.substring(1, 7), radix: 16) + 0xFF000000);
    return color;
  }

  static String toStr(dynamic val) {
    if (val == null) return "";
    if (val is int) return "$val";
    if (val is double) return "$val";
    if (val.toLowerCase() == "nan") return "";
    if (val.toLowerCase() == "null") return "";
    return "$val";
  }

  static int toInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is double) return val.toInt();
    if (val is String) {
      if (val.toLowerCase() == "nan") return 0;
      if (val.toLowerCase() == "null") return 0;
      return int.parse(val);
    }
    return 0;
  }

  static double toDouble(dynamic val) {
    if (val == null) return 0;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    if (val is String) {
      if (val.toLowerCase() == "nan") return 0.0;
      if (val.toLowerCase() == "null") return 0.0;
      return double.parse(val);
    }
    return 0.0;
  }
}
