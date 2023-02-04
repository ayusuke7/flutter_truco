
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_truco/io/message.dart';

class Client {
  
  Function(Message) onData;
  Function(dynamic) onError;
  
  bool connected = false;
  
  String host;
  int port;

  Socket? socket;

  Client({
    required this.port,
    required this.host,
    required this.onData,
    required this.onError,
  });

  Future<void> connect() async {
    try {
      socket = await Socket.connect(host, port);
      socket?.listen(_listenData,
        onDone: disconnect,
      );
      connected = true;
    } catch (exception) {
      connected = false;
      onError(exception);
    }
  }

  void _listenData(Uint8List uint8){
    var data = json.decode(String.fromCharCodes(uint8));
    var message = Message.fromJson(data);
    onData(message);
  }

  void sendMessage(Message message) {
    var encode = json.encode(message.toJson());
    socket?.write(encode);
  }
  
  Future<void> disconnect() async {
    if (socket != null) {
      await socket?.close();
      socket?.destroy();
      connected = false;
    }
  }
}