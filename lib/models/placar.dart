class Placar {

  int looser;
  int winner;

  Placar({
    this.looser = 0,
    this.winner = 0
  });

  void addLooser(){
    this.looser = this.looser+1;
  }
  
  void addWinner(){
    this.winner = this.winner+1;
  }

}