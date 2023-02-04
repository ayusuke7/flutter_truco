import 'package:flutter_truco/models/card.dart';

class Dealer {

  static List<CardModel> surfleDeck([int length = 40]){

    List<CardModel> tmpDeck = [];

    var naipe = 0;

    for(var i=0; i<length; i++){
      var value = i % 10;
      var number = value + 1;

      if (number == 1) number = 11;
      if (number == 2) number = 12;
      if (number == 3) number = 13;

      tmpDeck.add(CardModel(value: number, naipe: naipe ));

      if(value == 9) naipe += 1;
    }
    
    tmpDeck.shuffle();

    return tmpDeck;

  }

  static List<CardModel> dealerDeck(int max){
    return surfleDeck().getRange(0, max).toList();
  }
  
  static int? checkRounds(List<int> rounds){
      
    if(rounds.length < 2) return null;

    var result;
    var zero = rounds.contains(0);
    
    /* Testa caso de empate e retorna a eqp vencedora */
    if(rounds[0] == rounds[1] && !zero) {
      result = rounds.first;
    }else
    if(rounds[0] != rounds[1] && zero) {
      result = rounds.first == 0 ? rounds.last : rounds.first;
    }else
    if(rounds.length == 3 && zero) {
      result = rounds.last;
    }else 
    if(rounds.length == 3 && !zero){
      var res = rounds.where((w) => w == 1);
      result = res.length == 2 ? 1 : 2;
    }

    return result;

  }

  static CardModel? checkWinTruco(List<CardModel> jogadas){
    CardModel? win;

    jogadas.forEach((e) => print("${e.detail}\n"));

    var flipers = jogadas.where((f) => !f.flip).toList();
    var manils = flipers.where((m) => m.manil).toList();

    if(manils.isNotEmpty){
      manils.sort((a, b) => b.naipe.compareTo(a.naipe));
      win = manils.first;
    }else{
      flipers.sort((a, b) => b.value.compareTo(a.value));
      
      if(flipers[0].value > flipers[1].value){
        win = flipers[0];
      }else{
        var repeat = flipers.where((r) => r.value == flipers.first.value).toList();
        if(
          repeat.length == 2 && 
          repeat[0].player % 2 == repeat[1].player % 2
        ) {
          win = repeat.first;
        }
      }
    }

    return win;

  }
  
}