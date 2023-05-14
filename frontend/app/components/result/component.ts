import Component from '@glimmer/component';
import { service } from '@ember/service';
import GameService from 'frontend/services/game';
import { action } from '@ember/object';

interface ResultArgs {
  showModal: boolean;
}

export default class Result extends Component<ResultArgs> {
  @service('game') declare gameService: GameService;

  get winnerText() {
    return this.gameService.game.winner ? 'Winner!' : 'Draw!';
  }

  get symbols() {
    const winner = this.gameService.game.winner;
    const userSymbol = this.gameService.game.selected_symbol;
    const botSymbol = userSymbol === 'x' ? 'o' : 'x';
    if (winner === 'user') return [userSymbol];
    if (winner === 'bot') return [botSymbol];
    else return [userSymbol, botSymbol];
  }

  @action
  startNewGame() {
    this.gameService.resetGame();
  }
}
