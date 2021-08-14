import 'dart:async';
import 'dart:convert';

import 'package:android_long_task/long_task/service_data.dart';
import 'package:flutter/services.dart';

class AppClient {
  static const _CHANNEL_NAME = 'FSE_APP_CHANNEL_NAME';
  static const _START_SERVICE = 'START_SERVICE';
  static const _SET_SERVICE_DATA = 'SET_SERVICE_DATA';
  static const _GET_SERVICE_DATA = 'GET_SERVICE_DATA';
  static const _STOP_SERVICE = 'STOP_SERVICE';
  static const _RUN_DART_FUNCTION = 'RUN_DART_FUNCTION';
  static const _NOTIFY_UPDATE = 'NOTIFY_UPDATE';
  // ignore: close_sinks
  static final _serviceDataStreamController = StreamController<Map<String, dynamic>?>.broadcast();
  static final MethodChannel channel = MethodChannel(_CHANNEL_NAME)
    ..setMethodCallHandler((call) async {
      if (call.method == _NOTIFY_UPDATE) {
        var stringData = call.arguments as String?;
        if (stringData == null)
          _serviceDataStreamController.sink.add(null);
        else {
          Map<String, dynamic> json = jsonDecode(stringData);
          _serviceDataStreamController.sink.add(json);
        }
      }
    });

  // static Future<void> startService() async {
  //   await channel.invokeMethod(_START_SERVICE);
  // }

  static Future<void> stopService() async {
    await channel.invokeMethod(_STOP_SERVICE);
  }

  static Future<Map<String, dynamic>> execute(ServiceData initialData) async {
    await channel.invokeMethod(_SET_SERVICE_DATA, ServiceDataWrapper(initialData).toJson());
    await channel.invokeMethod(_START_SERVICE);
    var result = await channel.invokeMethod(_RUN_DART_FUNCTION, "");
    Map<String, dynamic> json = jsonDecode(result as String);
    return json;
  }

  static Future<Map<String, dynamic>?> getData() async {
    var stringData = await channel.invokeMethod(_GET_SERVICE_DATA) as String?;
    if (stringData == null) return null;
    if (stringData.toLowerCase() == 'null') return null;
    Map<String, dynamic> json = jsonDecode(stringData);
    return json;
  }

  static Stream<Map<String, dynamic>?> get updates {
    try {
      //dirty fix
      getData();
    } catch (e, stacktrace) {
      print(e);
      print(stacktrace);
    }
    return _serviceDataStreamController.stream;
  }
}
