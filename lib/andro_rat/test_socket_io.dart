// Flutter client
import 'package:socket_io_client/socket_io_client.dart' as IO;


Future<void> main() async {
  initConnection();
}

void initConnection() {
  IO.Socket socket = IO.io("http://localhost:6275", <String, dynamic> {
    "autoConnect": false,
    "transports": ["websocket"],
  });
  
  socket.onConnect((_) {
    print('[Connected]');
    socket.emit("join", );
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
  
  socket.on("deviceInfo", (_) {
    
  });

  socket.connect();
}
