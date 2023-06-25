import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import '/io/message.dart';
class Server {

  Function(Message)? onData;
  Function(String)? onError;
  
  final String host;
  final int port;

  ServerSocket? server;
  bool running = false;
  List<Socket> sockets = [];

  Server({
    required this.host,
    this.port = 4444
  });

  Future<void> start() async {
    try {
      server = await ServerSocket.bind(host, port);      
      server?.listen((Socket socket){
        socket.listen((Uint8List uint8){
          var data = String.fromCharCodes(uint8);
          var message = Message.fromJson(json.decode(data));
          message.host = socket.address.host;
          
          if(message.type == MessageTypes.connect){
            print("client connect ${message.data}");
            sockets.add(socket);
          }else 
          if(message.type == MessageTypes.disconect){
            print("client disconect ${message.data}");
            sockets.remove(socket);
          }
          
          if(onData != null){
            onData!(message);
          }

        });
      });
      running = true;
      print('Server listening on $host:$port');
    } catch (ex) {
      running = false;
      if(this.onError != null) {
        onError!("Error $ex");
      }
    }
  }

  Future<void> stop() async {
    print("stop server ${server?.address.host}");
    await server?.close();
    server = null;
    running = false;
  }

  void sendTo(String host, Message message){
    for (Socket socket in sockets) {
      if(socket.address.host == host){
        print('send message to $host');
        socket.write(json.encode(message.toJson()));
        break;
      }
    }
  }
  
  void sendIndex(int index, Message message){
    if(index < sockets.length){
      print('send message to ${sockets[index].address.host}');
      sockets[index].write(json.encode(message.toJson()));
    }
  }

  void broadcast(Message message) {
    print('send broadcasting');
    var encode = json.encode(message.toJson());
    for (Socket socket in sockets) {
      socket.write(encode);
    }
  }

}