import 'package:flutter/material.dart';
import 'package:flutter_truco/commons/assets.dart';
import 'package:flutter_truco/components/create_game.dart';
import 'package:flutter_truco/models/create_player.dart';
import 'package:flutter_truco/pages/mesa_page.dart';
import 'package:flutter_truco/pages/player_page.dart';
import 'package:flutter_truco/pages/server_page.dart';
import 'package:flutter_truco/utils/storage.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({ Key? key }) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  
  CreatePlayerModel? player;
  bool modePlayer = true;

  void _onTapMesa(){
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => ServerPage()
    ));
  }

  void _onTapPlayer(){
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          content: CreatePlayer(
            model: player,
            onTapSave: (model){
              Navigator.of(context).pop();
              setState(() { player = model; });
              Storage.saveModelPlayer(model);
            },
            onTapConnect: (model){
              Navigator.of(context).pop();
              setState(() { player = model; });
              Storage.saveModelPlayer(model);
              Navigator.push(context, MaterialPageRoute(
                builder: (ctx) => PlayerTruco(model: player)
              ));
            },
          ),
        );
      }
    );
  }
  
  void _getModelPlayer(){
    Storage.getModelPlayer().then((value) {
        if(value != null){
          print(value.toJson());
          setState(() {
            player = value;
          });
        }
      });
  }
 
  @override
  void initState() {
    super.initState();
    _getModelPlayer();
  }
  
  @override
  Widget build(BuildContext context) {
    var textStyle = TextStyle(
      color: Colors.white,
      fontFamily: Assets.gameria,
      fontSize: 22,
    );
    return Scaffold(
      backgroundColor: Colors.green[600],
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(20.0),
          alignment: Alignment.center,
          child: FittedBox(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Truco ", style: TextStyle(
                      fontFamily: "Gameria", 
                      fontSize: 60,
                      color: Colors.white
                    )),
                    Text("em Rede", style: TextStyle(
                      fontFamily: "Gameria", 
                      fontSize: 60,
                      color: Colors.yellow
                    )),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: _onTapMesa, 
                      child: Column(
                        children: [
                          Image.asset(
                            Assets.truco,
                            width: 150,
                            height: 150,
                          ),
                          const SizedBox(height: 15),
                          Text("MESA", style: textStyle),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        padding: EdgeInsets.all(15.0)
                      ),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: _onTapPlayer, 
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          player != null ? Image.asset("${player?.avatar}", 
                            width: 130, 
                            height: 130
                          ) : Icon(Icons.face, size: 100.0),
                          const SizedBox(height: 10),
                          Text(player?.name ?? "PLAYER", style: textStyle, softWrap: false,),
                          Text(player?.host ?? "", style: TextStyle(
                            fontSize: 18
                          )),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        padding: EdgeInsets.all(15.0),
                        fixedSize: Size(170, 220)
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}