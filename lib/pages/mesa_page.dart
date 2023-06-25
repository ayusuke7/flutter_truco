import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_truco/components/card_game.dart';
import 'package:flutter_truco/components/custom_avatar.dart';
import 'package:flutter_truco/io/message.dart';
import 'package:flutter_truco/io/server.dart';
import 'package:flutter_truco/models/card.dart';
import 'package:flutter_truco/models/mesa.dart';
import 'package:flutter_truco/models/player.dart';
import 'package:flutter_truco/utils/dealer.dart';
import 'package:loading_overlay/loading_overlay.dart';

class GameTruco extends StatefulWidget {
  
  final Server? server;
  final List<Player> players;

  const GameTruco({
    Key? key,
    this.server,
    required this.players
  }) : super(key: key);

  @override
  _GameTrucoState createState() => _GameTrucoState();
}

class _GameTrucoState extends State<GameTruco> {
  MesaModel mesa = MesaModel(vez: 0);

  List<Player> players = [];
  List<CardModel> jogadas = [];
  List<int> victorys = [], rounds = [];

  Player? truco;
  String? host;
  String? error; 

  CardModel? vira, winner;
  int eqp1 = 0, eqp2 = 0, vale = 1, ini = 0, partidas = 1;
  bool visible = false;
  bool playing = false; 

  void _startGame() async {
    setState(() {
      players = widget.players;
      for (var i = 0; i < players.length; i++) {
        players[i].id = i;
      }
    });
    
    await Future.delayed(Duration(seconds: 2));

    /* Uncomment code to distruition cards  */
    _distribuition();
  }

  void _sendBroadcastMesa({bool delay = false}) async {
    if (delay) await Future.delayed(Duration(seconds: 2));

    mesa.jogadas = jogadas.length;

    widget.server?.broadcast(Message(
      type: MessageTypes.statusMesa, 
      data: mesa.toJson()
    ));
  }

  void _executePlayerOrBot({bool delay = false}) async {
    var vez = mesa.vez;
    
    if (vez != null && players[vez].auto) {
      
      await Future.delayed(Duration(seconds: 2));
      CardModel card = Dealer.checkBestCard(
        players[vez].cards,
        jogadas
      );
      
      setState(() {
        jogadas.add(card);
        players[card.player].removeCard(card);
      });

      _checkVictory();
    } else {
      _sendBroadcastMesa(delay: delay);
    }
  }

  void _sendMessageTruco(Player player) {
    var index = players.indexOf(player);
    var target1 = 0, target2 = 2;
    
    if (index == 0 || index == 2) {
      target1 = 1;
      target2 = 3;
    }

    var message = Message(
      type: MessageTypes.getTruco, 
      data: "teste de string"
    );

    if (!players[target1].auto) {
      widget.server?.sendIndex(target1, message);
    }

    if (!players[target2].auto) {
      widget.server?.sendIndex(target2, message);
    }

  }

  void _checkVictory() async {
    await Future.delayed(Duration(milliseconds: 500));

    if (jogadas.length == 4) {
     
      CardModel? win = Dealer.checkWinTruco(jogadas);
      print("winner => ${win?.toJson()}");
      setState(() { winner = win; });

      await Future.delayed(Duration(seconds: 1));
      
      setState(() {
        jogadas.clear();
        victorys.add(win?.team ?? 0);
        mesa.vez = win?.player ?? mesa.vez;
        mesa.mao = 1;
      });

      print("victorys => $victorys");
      await Future.delayed(Duration(seconds: 2));
      _checkFinishRounds();
    } else {
       setState(() {
        mesa.vez = mesa.vez == 3 ? 0 : mesa.vez! + 1;
        mesa.mao = mesa.mao == 3 ? 1 : mesa.mao! + 1;
      });
      _executePlayerOrBot();
    }

  }

  void _checkFinishRounds() {
    var finish = Dealer.checkRounds(victorys);
    print("finish => $finish");

    if (finish != null) {
      var vez = ini == 3 ? 0 : ini + 1;
      setState(() {
        rounds.add(finish);
        ini = vez;
        mesa.vez = vez;

        if (finish == 1) eqp1 += vale;
        if (finish == 2) eqp2 += vale;
      });

      if(eqp1 < 12 && eqp1 < 12){
        _distribuition();
      }
    } else {
      _executePlayerOrBot();
    }
  }

  void _distribuition() async {
    
    var tmpDeck = Dealer.dealerDeck(13);
    var tmpVira = CardModel(
      value: tmpDeck.last.value,
      naipe: tmpDeck.last.naipe,
    );

    for (var i = 0; i < players.length; i++) {
      var pos = i * 3;
      var cards = tmpDeck.getRange(pos, pos + 3).toList();

      setState(() {
        players[i].setCards(cards, vira: tmpVira);
      });

      if (!players[i].auto) {
        var data = List.of(players[i].cards);
        /* Flip all card with black round */
        if(eqp1 == 11 && eqp2 == 11) {
          data.forEach((c) => c.flip = true);
        }
        var host = players[i].host;
        widget.server?.sendTo("$host", Message(
          type: MessageTypes.distribuition, 
          data: listCardToJson(data)
        ));
      }
    }

    setState(() {
      jogadas.clear();
      victorys.clear();

      vale = 1;
      vira = tmpVira;

      mesa.mao = 1;
      mesa.running = true;

      if (eqp1 >= 12 || eqp2 >= 12) {
        eqp1 = 0;
        eqp2 = 0;
      }
    });

    _executePlayerOrBot(delay: true);
  }

  void _onDataReceive(Message message) {
    print(message.toJson());

    switch (message.type) {
      case MessageTypes.sendCard:
        var card = CardModel.fromJson(message.data);
        setState(() {
          jogadas.add(card);
          players[card.player].removeCard(card);
        });
        _checkVictory();
        break;
      case MessageTypes.getTruco:
        var player = Player.fromJson(message.data);
        setState(() {
          truco = player;
        });
        break;
      default:
        break;
    }
  }

  void _onError(String error) {
    setState(() { error = error; });
  }

  void _stopServer() async {
    await widget.server?.stop();
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();

    if(widget.server != null){
      widget.server?.onData = _onDataReceive;
      widget.server?.onError = _onError;
    }

    _startGame();
  }

  @override
  void dispose() {
    if (widget.server != null) {
      widget.server?.stop();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[600],
      body: SafeArea(
        child: LoadingOverlay(
          isLoading: truco != null,
          color: Colors.black,
          opacity: 0.7,
          progressIndicator: _buildMessage(),
          child: Column(
            children: [
              _buildHeader(),
              _buildTable(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTable() {
    return Expanded(
      child: Stack(
        fit: StackFit.expand,
        alignment: AlignmentDirectional.center,
        children: [

          Positioned(
            right: 10,
            bottom: 0,
            child: TextButton.icon(
              icon: Icon(Icons.exit_to_app),
              label: Text('Finalizar'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white
              ),
              onPressed: _stopServer, 
            ),
          ),
    
          /* Avatar players positions */
          for (var i = 0; i < players.length; i++)
            Positioned(
              bottom: i == 0 ? 10 : null,
              left: i == 1 ? 10 : null,
              top: i == 2 ? 10 : null,
              right: i == 3 ? 10 : null,
              child: CustomAvatar(
                cards: players[i].cards.length,
                name: players[i].getName,
                backgroundColor: mesa.vez == i ? Colors.yellow : null,
                backgroundNameColor: players[i].color,
                asset: Image.asset("${players[i].getAsset}"),
              )
            ),
          
          /* Cards players */
          for (var i = 0; i < jogadas.length; i++)
            TweenAnimationBuilder<double>(
              curve: Curves.easeInOut,
              duration: Duration(milliseconds: 500),
              tween: Tween<double>(begin: 0, end: 200),
              builder: (context, value, child) {
                var jogada = jogadas[i];
                return Positioned(
                  bottom: jogada.player == 0 ? value : null,
                  left: jogada.player == 1 ? value : null,
                  top: jogada.player == 2 ? value : null,
                  right: jogada.player == 3 ? value : null,
                  child: RotatedBox(
                    quarterTurns: jogada.player,
                    child: CardGame(
                      mark: jogada.uui == winner?.uui,
                      card: jogada,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMessage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundColor: Colors.blue,
          radius: 45.0,
          child: Icon(Icons.bolt, size: 50, color: Colors.white
        )),
        const SizedBox(height: 20),
        Text("${truco?.name} pediu ${mesa.labelValor}",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 40.0,
            fontWeight: FontWeight.bold,
            color: Colors.white
          )
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.2,
      constraints: BoxConstraints(
        maxHeight: 130
      ),
      width: double.maxFinite,
      color: Colors.green[800],
      padding: EdgeInsets.all(7.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            child: Card(
              color: players[0].color,
              child: ListTile(
                title: Text("${players[0].getName}",
                  softWrap: false,
                  style: TextStyle(color: Colors.white, fontSize: 14)
                ),
                subtitle: Text("${players[2].getName}",
                  softWrap: false,
                  style: TextStyle(color: Colors.white, fontSize: 14)
                ),
                trailing: Text("$eqp1",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  )
                ),
              ),
            ),
          ),
          Container(
            width: 25.0,
            alignment: Alignment.center,
            child: const Text('X', style: TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.bold
            )),
          ),
          SizedBox(
            width: 100,
            child: Card(
              color: players[1].color,
              child: ListTile(
                title: Text("${players[1].getName}",
                  softWrap: false,
                  style: TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: Text("${players[3].getName}",
                  softWrap: false,
                  style: TextStyle(color: Colors.white, fontSize: 14)),
                trailing: Text("$eqp2",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          Container(
            width: 100,
            margin: EdgeInsets.only(left: 20),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.white)
              )
            ),
            child: ListTile(
              title: Text("Rodada",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold
                )
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    var icon = Icons.circle_outlined;
                    var color = Colors.white;
                
                    if (victorys.length > i && victorys[i] == 1) {
                      icon = Icons.circle;
                      color = players[0].color;
                    } else if (victorys.length > i && victorys[i] == 2) {
                      icon = Icons.circle;
                      color = players[1].color;
                    }
                
                    return Icon(icon, color: color, size: 20);
                  }),
                ),
              )
            ),
          ),
          Container(
            width: 100,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.white)
              )
            ),
            child: ListTile(
              title: Text("Valendo",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold
                )
              ),
              subtitle: Text("$vale",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold
                )
              )
            ),
          ),
          Container(
            width: 100,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.white)
              )
            ),
            child: ListTile(
              title: Text("Partidas",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold
                )
              ),
              subtitle: Text("$partidas",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold
                )
              )
            ),
          ),
          CardGame(
            card: vira,
            width: 65.0,
          ),
          
        ],
      ),
    );
  }
}
