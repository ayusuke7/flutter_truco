import 'package:flutter/material.dart';
import 'package:flutter_truco/components/custom_avatar.dart';
import 'package:flutter_truco/components/custom_button.dart';
import 'package:flutter_truco/io/message.dart';
import 'package:flutter_truco/io/server.dart';
import 'package:flutter_truco/models/player.dart';
import 'package:flutter_truco/pages/mesa_page.dart';
import 'package:flutter_truco/utils/helper.dart';
import 'package:network_info_plus/network_info_plus.dart';

class ServerPage extends StatefulWidget {
  const ServerPage({Key? key}) : super(key: key);

  @override
  State<ServerPage> createState() => _ServerPageState();
}

class _ServerPageState extends State<ServerPage> {
  final _network = NetworkInfo();

  List<Player> _players = [];

  String? _host;
  Server? _server;
  String? _message;
  
  void _getHost() async {
    var value = await _network.getWifiIP();
    if (value != null) {
      setState(() {  _host = '$value'; });
      _startServer();
    } else {
      _modalInput();
    }
  }

  void _startServer() async {
    _server = Server(host: _host!);
    _server?.onData = (Message m){
      switch (m.type) {
        case MessageTypes.connect:
          if (_players.length < 4) {
            var player = Player.fromJson(m.data);
            player.host = m.host;
            setState(() { _players.add(player); });
          }
          break;
        case MessageTypes.disconect:
          var player = Player.fromJson(m.data);
          var i = _players.indexWhere((p) => p.name == player.name);
          if(i > -1){
            setState(() {
              _players[i].auto = true;
              _players[i].name = null;
            });
          }
          break;
        default:
      }
    };
    _server?.onError = (String e) {
      setState(() { _message = e; });
    };

    await _server?.start();
  }

  void _modalInput() {
    showDialog(
      barrierDismissible: false,
      context: context, 
      builder: (ctx) => SimpleDialog(
        children: [
          Container(
            width: 250.0,
            margin: const EdgeInsets.symmetric(
              vertical: 50
            ),
            child: TextField(
              onChanged: (value){
                setState(() {
                  _host = value;
                });
              },
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: "ex: 192.169.1.2",
                fillColor: Colors.white,
                filled: true,
              ),
            ),
          ),
          CustomButton(
            icon: Icons.play_circle,
            label: "Iniciar Servidor",
            size: Size(250, 40),
            backgroundColor: Colors.blue,
            onPressed: () {
              if (Helper.isIpv4(_host)) {
                Navigator.pop(ctx);
                _startServer();
              }
            },
          ),
        ],
      )
    );
  }

  @override
  void initState() {
    super.initState();
    _getHost();
  }

  @override
  void dispose() {
    if (_server != null && _server!.running) {
      _server?.stop();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String title = "Inicie o Servidor para Jogar";
    String subtitle = "Informe o IP do servidor para iniciar!";

    bool running = _server != null && _server!.running;

    if(running){
      title = "Aguardando Jogadores se conectar";
      subtitle = "Conecte-se no IP do Servidor: ${_host ?? ''}";
    }

    return Scaffold(
      backgroundColor: Colors.green[600],
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ListTile(
              title: Text(title, 
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontFamily: "Gameria",
                  color: Colors.yellow
                )
              ),
              subtitle: Text(_message ?? subtitle,
                textAlign: TextAlign.center, 
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16
                )
              ),
            ),
            
            Container(
              margin: const EdgeInsets.symmetric(
                vertical: 50.0
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (i) {
                  var player = i < _players.length ? _players[i] : null;
                  return _buildPlayer(player);
                }),
              ),
            ),
            
            CustomButton(
              disable: _players.length < 4,
              icon: Icons.play_circle,
              label: "Iniciar Partida",
              size: Size(250, 40),
              backgroundColor: Colors.yellow,
              color: Colors.black,
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (_) => GameTruco(
                    server: _server,
                    players: _players
                  )
                ));
              },
            ),
            
          ],
        ),
      ),
    );
  }

  Widget _buildPlayer(Player? player) {
    if (player != null) {
      return CustomAvatar(
        onTap: (){
          var i = _players.indexOf(player);
          setState(() {
            _players.removeAt(i);
          });
        },
        name: "${player.getName}",
        backgroundNameColor: player.color,
        asset: Image.asset("${player.getAsset}"),
      );
    }

    return CustomAvatar(
      backgroundColor: Colors.green[800],
      asset: Icon(Icons.add, color: Colors.white),
      onTap: (){
        setState(() {
          _players.add(new Player(
            id: _players.length,
            name: 'BOT ${_players.length+1}',
            auto: true
          ));
        });
      },
    );
  }
}