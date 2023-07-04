import Route from '@ember/routing/route';
import Transition from '@ember/routing/transition';
import { service } from '@ember/service';
import GameService from 'frontend/services/game';

export default class ApplicationRoute extends Route {
  @service('game') declare gameService: GameService;

  async beforeModel(transition: Transition): Promise<Promise<unknown> | void> {
    await this.gameService.loadInitialGameState();
    return super.beforeModel(transition);
  }
}
