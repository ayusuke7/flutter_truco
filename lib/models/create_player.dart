import 'dart:convert';

String configToJson(CreatePlayerModel data) => json.encode(data.toJson());

CreatePlayerModel configFromJson(String str) => CreatePlayerModel.fromJson(json.decode(str));

class CreatePlayerModel {

  String? avatar;
  String name;
  String host;

  CreatePlayerModel({
    required this.host,
    required this.name,
    this.avatar,
  });

  factory CreatePlayerModel.fromJson(Map<String, dynamic> json) => CreatePlayerModel(
    avatar: json["avatar"],
    name: json["name"],
    host: json["host"],
  );

  Map<String, dynamic> toJson() => {
    "avatar": avatar,
    "name": name,
    "host": host,
  };
}