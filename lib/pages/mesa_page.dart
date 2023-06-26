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

  CardModel? winner;
  CardModel? vira;
  Player? truco;
  String? host;
  String? error; 

  int eqp1 = 0, eqp2 = 0, vale = 1, ini = 0, partidas = 1;
  bool visible = false, playing = false; 

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

  void _sendBroadcastMesa({ bool delay = false }) async {
    if (delay) await Future.delayed(Duration(seconds: 2));

    mesa.jogadas = jogadas.length;

    widget.server?.broadcast(Message(
      type: MessageTypes.statusMesa, 
      data: mesa.toJson()
    ));
  }

  void _executePlayerOrBot({ bool delay = false }) async {
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
  
    if (jogadas.length == 4) {
     
      CardModel? cardWin = Dealer.checkWinTruco(jogadas);
      print("CARD WINNER => ${cardWin?.detail}");
      setState(() { winner = cardWin; });

      await Future.delayed(Duration(seconds: 2));
      
      /* Limpa a mesa e marca a vez do jogador */
      setState(() {
        jogadas.clear();
        victorys.add(cardWin?.team ?? 0);
        mesa.vez = cardWin?.player ?? mesa.vez;
        mesa.mao = 1;
      });

      print('MESA => ${mesa.toJson()}');
      _checkFinishRounds();
    } else {
      await Future.delayed(Duration(milliseconds: 500));
      setState(() {
        mesa.vez = mesa.vez == 3 ? 0 : mesa.vez! + 1;
        mesa.mao = mesa.mao == 3 ? 1 : mesa.mao! + 1;
      });
      _executePlayerOrBot();
    }

  }

  void _checkFinishRounds() async {
    print("VICTORYS => $victorys");
    var teamWinner = Dealer.checkRounds(victorys);

    if (teamWinner != null) {
      print("TEAM WINNER => $teamWinner");
      
      var vez = ini == 3 ? 0 : ini + 1;
      setState(() {
        rounds.add(teamWinner);
        ini = vez;
        mesa.vez = vez;

        if (teamWinner == 1) eqp1 += vale;
        if (teamWinner == 2) eqp2 += vale;
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

    /* distribuition cards to all players */
    for (var i = 0; i < players.length; i++) {
      var pos = i * 3;
      var cards = tmpDeck.getRange(pos, pos + 3).toList();

      setState(() { 
        var newCards = Dealer.updateCards(cards,
          vira: tmpVira,
          player: players[i]
        );
        players[i].setCards(newCards); 
      });

      /* send card to player client connected */
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

    /* restart values game */
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

    if(widget.server != null && 
       widget.server!.running
    ){
      widget.server?.onData = _onDataReceive;
      widget.server?.onError = _onError;
    }

    _startGame();
  }

  @override
  void dispose() {
    if (widget.server != null && 
        widget.server!.running
      ) {
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
          child: Row(
            children: [
              _buildTable(),
              _buildSideMenu()
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
    
          /* Avatar players positions */
          for (var i = 0; i < players.length; i++)
            _buildAvatar(players[i], i),
          
          /* Cards players */
          for (var i = 0; i < jogadas.length; i++)
            _buildCard(jogadas[i], i)
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

  Widget _buildSideMenu() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.2,
      constraints: BoxConstraints(
        maxWidth: 250
      ),
      color: Colors.green[800],
      padding: EdgeInsets.all(7.0),
      child: ListView(
        children: [
          CardGame(
            card: vira,
            width: 70.0,
          ),
          Container(
            margin: EdgeInsets.symmetric(
              vertical: 10.0
            ),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white))
            ),
            child: TextButton.icon(
              label: Text('Sair'),
              icon: Icon(Icons.exit_to_app),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white
              ),
              onPressed: _stopServer, 
            ),
          ),
          ListTile(
            title: Text("Rodada",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold
              )
            ),
            trailing: SizedBox(
              width: 60,
              child: Row(
                children: List.generate(3, (i) {
                  var icon = Icons.circle_outlined;
                  var color = Colors.white;
                    
                  if (victorys.length > i && victorys[i] == 0) {
                    icon = Icons.circle;
                  } else 
                  if (victorys.length > i && victorys[i] == 1) {
                    icon = Icons.circle;
                    color = players[0].color;
                  } else 
                  if (victorys.length > i && victorys[i] == 2) {
                    icon = Icons.circle;
                    color = players[1].color;
                  }
              
                  return Icon(icon, color: color, size: 20);
                }),
              ),
            )
          ),
          ListTile(
            title: Text("Partidas",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold
              )
            ),
            trailing: Text("$partidas",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold
              )
            )
          ),
          ListTile(
            title: Text("Valendo",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold
              )
            ),
            trailing: Text("$vale",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold
              )
            )
          ),
          Divider(color: Colors.white, height: 40.0),
          Card(
            color: players[0].color,
            child: ListTile(
              dense: true,
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
          Card(
            color: players[1].color,
            child: ListTile(
              dense: true,
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
        ],
      ),
    );
  }

  Widget _buildAvatar(Player player, int i) {
    return Positioned(
      bottom: i == 0 ? 5 : null,
      left: i == 1 ? 5 : null,
      top: i == 2 ? 5 : null,
      right: i == 3 ? 5 : null,
      child: CustomAvatar(
        cards: player.cards.length,
        name: player.getName,
        backgroundColor: mesa.vez == i ? Colors.yellow : null,
        backgroundNameColor: player.color,
        asset: Image.asset("${player.getAsset}"),
        onTap: (){
          if (mesa.vez == player.id && player.auto) {
            _executePlayerOrBot();
          }
        },
      )
    );
  }

  Widget _buildCard(CardModel jogada, int i) {
    var size = MediaQuery.of(context).size;
    var end = i % 2 == 0 ? size.height / 2 : size.width / 3.5;
    
    return TweenAnimationBuilder<double>(
      curve: Curves.easeInOut,
      duration: Duration(milliseconds: 500),
      tween: Tween<double>(begin: 0, end: end),
      builder: (context, value, child) {
        var mark = jogada.uui == winner?.uui;
        return Positioned(
          bottom: jogada.player == 0 ? value : null,
          left: jogada.player == 1 ? value : null,
          top: jogada.player == 2 ? value : null,
          right: jogada.player == 3 ? value : null,
          child: RotatedBox(
            quarterTurns: jogada.player,
            child: CardGame(
              width: size.height * 0.15,
              card: jogada,
              mark: mark,
            ),
          ),
        );
      },
    );
  }

}
