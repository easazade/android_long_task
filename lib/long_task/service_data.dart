import 'dart:convert';

abstract class ServiceData {
  String toJson();

  String get notificationTitle;

  String get notificationDescription;
}

class ServiceDataWrapper {
  ServiceData _serviceData;

  ServiceDataWrapper(this._serviceData);

  String toJson() {
    print("something");
    Map<String, dynamic> json = jsonDecode(_serviceData.toJson());
    json["notif_title"] = _serviceData.notificationTitle;
    json["notif_description"] = _serviceData.notificationDescription;
    return jsonEncode(json);
  }
}
