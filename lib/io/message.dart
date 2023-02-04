import 'package:flutter_truco/models/mesa.dart';

enum MessageTypes {
  CONNECT,
  DISCONECT,
  SEND_CARD,
  DISTRIBUITION,
  GET_TRUCO,
  ACCEPT_TRUCO,
  STATUS_MESA,
}
class Message {

  final dynamic data;
  final MessageTypes type;
  final MesaModel? mesa;
  String? host;

  Message({ 
    required this.type, 
    required this.data,
    this.mesa,
    this.host
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    type: json["type"], 
    data: json["data"],
    mesa: json["mesa"],
    host: json["host"],
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "data": data,
    "mesa": mesa,
    "host": host,
  };

}