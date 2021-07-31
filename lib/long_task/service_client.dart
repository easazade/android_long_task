import 'dart:convert';

import 'package:android_long_task/long_task/service_data.dart';
import 'package:flutter/services.dart';

class ServiceClient {
  static const _CHANNEL_NAME = "APP_SERVICE_CHANNEL_NAME";
  static const _SET_SERVICE_DATA = 'SET_SERVICE_DATA';
  static const _STOP_SERVICE = 'stop_service';
  static const _END_EXECUTION = 'END_EXECUTION';
  static var channel = MethodChannel(_CHANNEL_NAME);

  static Future update(ServiceData data) async {
    var dataWrapper = ServiceDataWrapper(data);
    await channel.invokeMethod(_SET_SERVICE_DATA, dataWrapper.toJson());
  }

  static setExecutionCallback(Future action(Map<String, dynamic> initialData)) {
    channel.setMethodCallHandler((call) async {
      var json = jsonDecode(call.arguments as String);
      await action(json);
    });
  }

  static Future<void> endExecution(ServiceData data) async {
    var dataWrapper = ServiceDataWrapper(data);
    return channel.invokeMethod(_END_EXECUTION, dataWrapper.toJson());
  }

  static Future<String?> stopService() => channel.invokeMethod<String?>(_STOP_SERVICE);
}
