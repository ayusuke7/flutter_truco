import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_truco/models/card.dart';

class Player {

  List<CardModel> _cards = [];

  String? asset;
  String? name;
  String? host;
  
  bool auto;
  int player;
  int team;
  int id;

  Player({
    required this.id,
    this.auto = false,
    this.team = 0,
    this.player = -1,
    this.name,
    this.asset,
    this.host
  });

  List<CardModel> get cards => _cards;

  Color get color {
    return team == 1 ? Colors.blue : Colors.red;
  }
  
  void printCards(){
    _cards.forEach((e) => print("${e.detail}"));
  }

  void setCards(List<CardModel> newCards){
    _cards = newCards;
  }

  void removeCard(CardModel card){
    _cards.removeWhere((c) => c.uui == card.uui);
  }

  void clearCards(){
    _cards.clear();
  }

  String get getAsset {
    if(asset == null){
      var rd = Random.secure().nextInt(11) + 1;
      asset = "assets/images/avatar$rd.png";
    }

    return "$asset";
  }

  String get getName {
    if(name != null) return "$name";
    return "BOT $id";
  }

  factory Player.fromJson(Map<String, dynamic> json) => Player(
      name: json["name"],
      id: json["id"],
      auto: json["auto"],
      asset: json["asset"],
      host: json["host"],
      team: json["team"],
  );

  Map<String, dynamic> toJson() => {
      "name": name,
      "id": id,
      "auto": auto,
      "asset": asset,
      "host": host,
      "team": team,
  };

}