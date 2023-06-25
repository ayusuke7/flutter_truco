import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_truco/models/card.dart';
import 'package:flutter_truco/models/placar.dart';

class Player {

  final Placar placar = new Placar();

  List<CardModel> _cards = [];

  String? asset;
  String? name;
  String? host;
  
  bool auto;
  int team;
  int id;

  Player({
    required this.id,
    this.auto = false,
    this.team = 0,
    this.name,
    this.asset,
    this.host
  });

  List<CardModel> get cards => _cards;

  Color get color {
    if(id == 0 || id == 2) return Colors.blue;
    return Colors.red;
  }
  
  void printCards(){
    _cards.forEach((e) => print("${e.detail}"));
  }

  void setCards(List<CardModel> newCards, { CardModel? vira }){
    _cards.clear();
    _cards = newCards.map((e){
      var card = CardModel(
        player: id,
        team: team,
        naipe: e.naipe, 
        value: e.value,
      );
      if(vira != null){
        var manil = vira.value == 13 ? 4 : vira.value + 1;
        card.manil = e.value == manil;
      }
      return card;
    }).toList();
  }
  
  void removeCard(CardModel card){
    _cards.removeWhere((c) => c.uui == card.uui);
  }
  
  void addCard(CardModel card){
    _cards.insert(0, CardModel(
      naipe: card.naipe, 
      value: card.value,
      player: id
    ));
  }
  
  void addCards(List<CardModel> newCards){
    _cards.insertAll(0, newCards.map((e) => CardModel(
      naipe: e.naipe, 
      value: e.value,
      player: id
    )));
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