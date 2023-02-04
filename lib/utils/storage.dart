import 'dart:async';
import 'package:flutter_truco/models/create_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Storage {

  static final String configs = 'dl@player';
  static final String mode = 'dl@mode';

  static Future<bool> save(String key, String data) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, data);
  }

  static Future<bool> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }  

  static Future<String?> gett(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<bool> clear() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }

  static Future<bool> saveMode(bool value){
    return save(mode, "$value");
  }
  
  static Future<String?> getMode() async {
    return await gett(mode);
  }
  
  static Future<bool> saveModelPlayer(CreatePlayerModel model){
    var data = configToJson(model);
    return save(configs, data);
  }
  
  static Future<CreatePlayerModel?> getModelPlayer() async {
    var data = await gett(configs);
    
    if(data != null) return configFromJson(data);

    return null;
  }

}