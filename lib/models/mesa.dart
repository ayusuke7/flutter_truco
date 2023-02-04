
class MesaModel {

  int? vez;
  int? mao;
  int? valendo;
  int jogadas;

  bool running;
  bool escuro;

  MesaModel({ 
    this.jogadas = 0,
    this.valendo = 1,
    this.vez,
    this.mao,
    this.escuro = false,
    this.running = false,
  });

  String get labelValor {
    return valendo == 1 
      ? "Truco" : valendo == 3 
      ? "Seis" : valendo == 6 
      ? "Nove" 
      : "Doze";
  }

  factory MesaModel.fromJson(Map<String, dynamic> json) => MesaModel(
    vez: json["vez"],
    mao: json["mao"],
    running: json["running"],
    jogadas: json["jogadas"],
    valendo: json["valendo"],
    escuro: json["escuro"],
  );

  Map<String, dynamic> toJson() => {
    "vez": vez,
    "mao": mao,
    "running": running,
    "jogadas": jogadas,
    "escuro": escuro,
    "valendo": valendo,
  };
}