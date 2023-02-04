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
          
          if(message.type == MessageTypes.CONNECT){
            sockets.add(socket);
            print("client connect ${message.data}");
          }else 
          if(message.type == MessageTypes.DISCONECT){
            sockets.remove(socket);
            print("client disconect ${message.data}");
          }
          
          if(this.onData != null){
            this.onData!(message);
          }

        });
      });
      this.running = true;
      print('Server listening on $host:$port');

    } catch (ex) {
      this.running = false;

      if(this.onError != null) {
        this.onError!("Error $ex");
      }
    }
  }

  Future<void> stop() async {
    await this.server?.close();
    print("stop server ${server?.address.host}");
    this.server = null;
    this.running = false;
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