import 'dart:math';
import 'package:flutter_truco/models/card.dart';

class Dealer {

  static List<CardModel> surfleDeck([int length = 40]){

    List<CardModel> tmpDeck = [];

    var naipe = 0;

    for(var i=0; i<length; i++){
      var value = i % 10;
      var number = value + 1;

      if (number < 4) number += 10;

      tmpDeck.add(CardModel(value: number, naipe: naipe));

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

    /* filtra apenas as que não estão virada */
    var flipers = jogadas.where((f) => !f.flip).toList();
    var manils = flipers.where((m) => m.manil).toList();

    /* Verifica se tem manilhas e retorna o vencedor delas */
    if (manils.isNotEmpty) {
      manils.sort((a, b) => b.naipe.compareTo(a.naipe));
      win = manils.first;
    } else {

      /* Orderna pelos valores de maior p/ menor e testa 0 e 1 */
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
  
  static CardModel checkBestCard(List<CardModel> hand, List<CardModel> deck) {
    if(hand.length == 1) return hand.first;
    
    /* Ordena da mais forte > fraca */
    hand.sort((a, b) => b.value.compareTo(a.value));

    /* Filtra as manilhas */
    var manils = hand.where((m) => m.manil).toList();

    /* Primeira ou Segunda Jogada */
    if (deck.length == 0 || deck.length == 1) {
      /* Se tiver 1 manilha de OURO ou ESPADA joga */
      if (manils.length == 1 && manils.first.value < 2){
        return manils.first;
      }else 
      /* Se tive +1 manilha joga a mais fraca */
      if (manils.length > 1) {
       return manils.last; 
      }
    } else
    /* Terceiro a Jogar */ 
    if (deck.length == 2){
      /* Se o companheiro não venceu a primeira jogar a mais forte */
      if (deck[0].value < deck[1].value) {
        return manils.isNotEmpty ? manils.last : hand.first;
      }
    } else
    /* Ultimo a Jogar */ 
    if (deck.length == 3){
      /* Se o companheiro não venceu a segunda jogar a mais forte */
      if (deck[1].value < deck[0].value && 
          deck[1].value < deck[2].value) {
        return manils.isNotEmpty ? manils.last : hand.first;
      }
    }
    
    /* Joga a mais fraca */
    return hand.last;
  }
}