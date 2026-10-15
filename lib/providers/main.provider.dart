import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nightout/models/app/app.config.dart';
import 'package:nightout/models/app/app.info.dart';
import 'package:nightout/models/app/noti.data.dart';
import 'package:nightout/utils/util.dart';

class MainState {
  MainState({
    this.locale = const Locale('th'),
    this.appInfo = const AppInfo(),
    this.appConfig = const AppConfig(),
    this.keyId = '',
    this.transId = '',
    this.key = '',
    this.token = '',
    this.notiToken = '',
    DateTime? createTime,
    this.notiData,
  }) : createTime = createTime ?? DateTime.now();

  final Locale locale;
  final AppInfo appInfo;
  final AppConfig appConfig;

  final String keyId;
  final String transId;
  final String key;
  final String token;
  final String notiToken;
  final DateTime createTime;
  final NotiData? notiData;

  double get osVersion => Util.toDouble(appInfo.osVersion);

  MainState copyWith({
    Locale? locale,
    AppInfo? appInfo,
    AppConfig? appConfig,
    String? keyId,
    String? transId,
    String? key,
    String? token,
    String? notiToken,
    DateTime? createTime,
    NotiData? Function()? notiData,
  }) {
    return MainState(
      locale: locale ?? this.locale,
      appInfo: appInfo ?? this.appInfo,
      appConfig: appConfig ?? this.appConfig,
      keyId: keyId ?? this.keyId,
      transId: transId ?? this.transId,
      key: key ?? this.key,
      token: token ?? this.token,
      notiToken: notiToken ?? this.notiToken,
      createTime: createTime ?? this.createTime,
      notiData: notiData != null ? notiData() : this.notiData,
    );
  }
}

class MainNotifier extends Notifier<MainState> {
  @override
  MainState build() => MainState();

  void setLocale(Locale locale) {
    state = state.copyWith(locale: locale);
  }

  void setAppInfo(AppInfo appInfo) {
    state = state.copyWith(appInfo: appInfo);
  }

  void setAppConfig(AppConfig appConfig) {
    state = state.copyWith(appConfig: appConfig);
  }

  void setKeyId(String keyId) {
    state = state.copyWith(keyId: keyId);
  }

  void setTransId(String transId) {
    state = state.copyWith(transId: transId);
  }

  void setKey(String key) {
    state = state.copyWith(key: key);
  }

  void setToken(String token) {
    state = state.copyWith(token: token);
  }

  void setNotiToken(String notiToken) {
    state = state.copyWith(notiToken: notiToken);
  }

  void clearSession() {
    state = state.copyWith(
      key: '',
      token: '',
      keyId: '',
      transId: '',
      notiData: () => null,
    );
  }
}

final mainProvider = NotifierProvider<MainNotifier, MainState>(MainNotifier.new);
