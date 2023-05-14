import Component from '@glimmer/component';
import { action } from '@ember/object';
import { service } from '@ember/service';
import GameService from 'frontend/services/game';

interface NewGameArgs {
  showModal: boolean;
}

export default class NewGame extends Component<NewGameArgs> {
  @service('game') gameService: GameService;

  @action
  async handleClick(symbol: 'x' | 'o') {
    await this.gameService.createNewGame(symbol);
  }
}
