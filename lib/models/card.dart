import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_truco/commons/assets.dart';
import 'package:flutter_truco/commons/enums.dart';

List<CardModel> listCardFromJson(String str) => List<CardModel>.from(
  json.decode(str).map((x) => CardModel.fromJson(x)
));

String listCardToJson(List<CardModel> data) => json.encode(
  List<dynamic>.from(data.map((x) => x.toJson())
));

class CardModel {

  final int naipe;
  final int value;
  
  int player;
  bool manil;
  bool flip;

  CardModel({
    required this.value,
    required this.naipe,
    this.player = 0,
    this.flip = false,
    this.manil = false
  });

  String get uui => "$player-$value-$naipe";

  String get label {
    if(value == 11) return "A";
    else if(value == 12) return "2";
    else if(value == 13) return "3";
    else if(value == 8) return "Q";
    else if(value == 9) return "J";
    else if(value == 10) return "K";
    return "$value";
  }

  String get detail {
    return "Player: $player, Card: $label, Value: $value, Naipe: $naipe, Manil: $manil";
  }

  Color get color {
    if(naipe == 1 || naipe == 3) return Colors.black;
    return Colors.red;
  }

  String get asset {

    var type = NaipeType.values[naipe];
    
    if(type == NaipeType.HEART){
      return Assets.heart;
    }else 
    if(type == NaipeType.DIAMOND){
      return Assets.diamond;
    }else 
    if(type == NaipeType.CLUBE){
      return Assets.club;
    }else 
    if(type == NaipeType.SPADE){
      return Assets.spade;
    }

    return "";

  }

  String get naipeLabel {
    return NaipeType.values[naipe].toString();
  }

  factory CardModel.fromJson(Map<String, dynamic> json) => CardModel(
      naipe: json["naipe"],
      value: json["value"],
      player: json["player"],
      manil: json["manil"],
      flip: json["flip"],
  );

  Map<String, dynamic> toJson() => {
      "naipe": naipe,
      "value": value,
      "player": player,
      "manil": manil,
      "flip": flip,
  };

}