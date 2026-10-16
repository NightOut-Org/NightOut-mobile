import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class Download {
  static Future<Uint8List?> readByte(String url) async {
    Uri uri = Uri.parse(url);
    try {
      ByteData imageData = await NetworkAssetBundle(uri).load("");
      if (imageData.lengthInBytes < 1) return null;
      return imageData.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  static Future<String?> save(
    String url, {
    String? mime,
    String? filename,
  }) async {
    Uri uri = Uri.parse(url);
    Directory dir = await getTemporaryDirectory();
    String fname = filename ?? ("${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}.${mime ?? ""}");
    String tempPath = "${dir.path}/$fname";
    try {
      Response res = await Dio().downloadUri(uri, tempPath);
      if (res.statusCode == 200) {
        return tempPath;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
