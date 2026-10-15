import 'package:nightout/models/api/res.token.dart';
import 'package:nightout/models/api/rest.api.dart';

class RestException implements Exception {
  final RestApi rest;

  RestException(this.rest);

  String get code => rest.errorCode;
  String get message => rest.errorDesc;
  String get messageInternal => rest.errorDescInternal;
  dynamic get data => rest.data;

  @override
  String toString() {
    return "RestException: rest=${rest.toString()}";
  }
}

class RestTokenException implements Exception {
  final ResToken rest;

  RestTokenException(this.rest);

  String get code => rest.errorCode;
  String get message => rest.errorDesc;
  dynamic get data => rest.data;

  @override
  String toString() {
    return "RestException: rest=${rest.toString()}";
  }
}

class AppException implements Exception {
  final String message;

  AppException(
    this.message,
  );

  String getMessage() {
    return message;
  }

  @override
  String toString() {
    return message;
  }
}
