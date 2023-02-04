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
  Server? _server;
  String? _host;
  String? _message;
  
  void _getHost() async {
    try {
      var value = await _network.getWifiIP();
      setState(() { _host = '$value'; });
    } catch (e) {
      print(e);
    }
  }

  void _startServer() async {
    _server = Server(host: '$_host');
    _server?.onData = (Message m){
      switch (m.type) {
        case MessageTypes.CONNECT:
          if (_players.length < 4) {
            var player = Player.fromJson(m.data);
            player.host = m.host;
            setState(() { _players.add(player); });
          }
          break;
        case MessageTypes.DISCONECT:
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

  @override
  void initState() {
    super.initState();
    _getHost();
  }

  @override
  Widget build(BuildContext context) {
    String title = "Aguardando Jogadores se conectar";
    String subtitle = "Conecte no servidor: $_host";

    var run = _server != null && _server!.running;

    if(!run){
      title = "Inice o Servidor para Jogar";
      subtitle = "Informe o IP do servidor para iniciar!";
    }


    return Scaffold(
      backgroundColor: Colors.green[600],
      body: Container(
        width: double.maxFinite,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
            
            if(!run) Container(
              margin: const EdgeInsets.symmetric(
                vertical: 50
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for(var i=0; i<4; i++)
                    i < _players.length
                    ? CustomAvatar(
                        onTap: (){
                          if(_players.length == 4){
                            setState(() {
                              var tmp = _players.removeAt(i);
                              var index = i < 3 ? i+1 : 0;
                              _players.insert(index, tmp);
                            });
                          }
                        },
                        name: "${_players[i].getName}",
                        backgroundNameColor: i % 2 == 0 ? Colors.red : Colors.blue,
                        asset: Image.asset("${_players[i].getAsset}"),
                      )
                    : CustomAvatar(
                        asset: Icon(Icons.add, color: Colors.white),
                        onTap: (){
                          setState(() {
                            _players.add(new Player(
                              number: _players.length,
                              auto: true
                            ));
                          });
                        },
                      ),
                ],
              ),
            ),

            if(!run) Container(
              width: 250.0,
              margin: const EdgeInsets.symmetric(
                vertical: 50
              ),
              child: TextField(
                onChanged: (value){
                  setState(() { _host = value; });
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "ex: 192.169.1.2",
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white
                    )
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            
            CustomButton(
              disable: !Helper.isIpv4(_host),
              icon: Icons.play_circle,
              label: "Iniciar Servidor",
              size: Size(250, 40),
              backgroundColor: Colors.blue,
              onPressed: _startServer,
            ),
            
            const SizedBox(height: 10),
            
            CustomButton(
              //disable: _players.length == 0 || _players.length == 4,
              icon: Icons.add_circle,
              label: "Adicionar BOT",
              size: Size(250, 40),
              backgroundColor: Colors.cyan,
              onPressed: (){
                setState(() {
                  _players.add(new Player(
                    number: _players.length,
                    auto: true
                  ));
                });
              },
            ),
            
            const SizedBox(height: 10),
            
            CustomButton(
              disable: _players.length != 4,
              icon: Icons.play_circle,
              label: "Iniciar Partida",
              size: Size(250, 40),
              backgroundColor: Colors.blue,
              onPressed: (){
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

  Widget _buildCreateServer() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("Iniciar Servidor",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 15),

        Text("Não foi possivel configurar o IP do Servidor!\nPor favor, Informe manualmente!",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white,),
        ),
        
        CustomButton(
          icon: Icons.play_arrow,
          label: 'Iniciar Servidor',
          backgroundColor: Colors.blue,
          margin: EdgeInsets.only(bottom: 15),
          size: Size(250, 40),
          onPressed: (){
            setState(() {
              _server = Server(host: '$_host');
            });
          },
        ),
        CustomButton(
          icon: Icons.circle_outlined,
          label: 'Jogar c/ BOT',
          backgroundColor: Colors.yellow,
          color: Colors.black,
          size: Size(250, 40),
          onPressed: (){
            
          },
        ),
      ],
    );
  }

}