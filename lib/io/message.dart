import 'package:flutter_truco/models/mesa.dart';

enum MessageTypes {
  connect,
  disconect,
  sendCard,
  distribuition,
  getTruco,
  acceptTruco,
  statusMesa,
}

MessageTypes getType(String typeMessage) {
  return MessageTypes
  .values
  .firstWhere((m) => m.name == typeMessage);
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
    type: getType(json["type"]), 
    data: json["data"],
    mesa: json["mesa"],
    host: json["host"],
  );

  Map<String, dynamic> toJson() => {
    "type": type.name,
    "data": data,
    "mesa": mesa,
    "host": host,
  };

}