import Component from '@glimmer/component';
import { service } from '@ember/service';
import { action } from '@ember/object';
import GameService from 'frontend/services/game';
import ApiService from 'frontend/services/api';

export default class GameComponent extends Component {
  @service('game') gameService: GameService;
  @service('api') api: ApiService;

  get symbol() {
    return this.gameService.game?.selected_symbol;
  }

  @action async onPlay(
    player: string | null,
    row_idx: number,
    col_idx: number
  ) {
    if (!player) await this.gameService.updateGame(row_idx, col_idx);
  }
}
