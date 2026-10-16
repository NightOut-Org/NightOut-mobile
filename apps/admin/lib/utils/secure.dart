import 'dart:convert';
import 'dart:math';

class Es {
  List<int> e(String a) {
    var a1 = utf8.encode(a);
    var a2 = a1.reversed.toList();
    var a3 = a2.asMap().entries.map((e) => (e.key % 2 == 0) ? e.value + 1 : e.value - 1).toList();
    var a4 = a3.asMap().entries.map((e) => (e.key % 3 == 0) ? e.value * 2 : e.value).toList();
    return a4;
  }

  String d(List<int> b) {
    var b1 = b.asMap().entries.map((e) => (e.key % 3 == 0) ? (e.value / 2).round() : e.value).toList();
    var b2 = b1.asMap().entries.map((e) => (e.key % 2 == 0) ? e.value - 1 : e.value + 1).toList();
    var b3 = b2.reversed.toList();
    return utf8.decode(b3);
  }
}

class Secure {
  static int keySize = 16;
  static int a = 5;
  static int b = 9;
  static String char = '0123456789';

  static String genKeyId() {
    List<String> keyId = [];
    for (var i = 0; i < keySize; i++) {
      double val = Random.secure().nextDouble() * char.length;
      keyId.add(char[val.floor()]);
    }
    return keyId.join();
  }

  static String genCreateKey(String keyId) {
    List<int> crKey = [];
    for (var i = 0; i < keySize; i++) {
      crKey.add(pow(a, int.parse(keyId[i])).toInt() % b);
    }
    return crKey.join();
  }

  static String genDynamicKey(String keyId, String pk) {
    List<int> key = [];
    for (var i = 0; i < keySize; i++) {
      key.add(pow(int.parse(pk[i]), int.parse(keyId[i])).toInt() % b);
    }
    return key.join();
  }

  static String toBase64Length16(String txt) {
    if (txt.isEmpty) return "";
    String b64 = base64.encode(utf8.encode(txt));
    return b64.substring(0, 16);
  }
}
