import Controller from '@ember/controller';
import { service } from '@ember/service';
import GameService from 'frontend/services/game';

export default class ApplicationController extends Controller {
  @service('game') declare gameService: GameService;

  get showNewGameModal() {
    return !this.gameService.game;
  }

  get showResultModal() {
    return this.gameService.game?.finished;
  }
}
