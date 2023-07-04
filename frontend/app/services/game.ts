import Service, { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import Cookies from 'js-cookie';
import ApiService, {
  ErrorResponse,
  GameResponse,
  MoveResponse,
  Player,
} from 'frontend/services/api';
import ToastService from 'frontend/services/toast';

export default class GameService extends Service {
  @service('toast') toast: ToastService;
  @service('api') api: ApiService;
  @tracked game: GameResponse | null = null;

  resetGame() {
    this.game = null;
    Cookies.remove('ttt_game');
  }

  async loadInitialGameState() {
    const currentGame = Cookies.get('ttt_game');
    if (currentGame) {
      try {
        this.game = await this.api.request('GET', `games/${currentGame}`);
      } catch (e) {
        const errors = e as ErrorResponse;
        errors.forEach((err) => {
          this.toast.show(err.detail, 'error');
        });
      }
    }
  }

  async createNewGame(selected_symbol: string) {
    try {
      this.game = await this.api.request('POST', 'games', { selected_symbol });
      Cookies.set('ttt_game', String(this.game.id));
    } catch (e) {
      const errors = e as ErrorResponse;
      errors.forEach((err) => {
        this.toast.show(err.detail, 'error');
      });
    }
  }

  async updateGame(row_idx: number, col_idx: number): Promise<void> {
    if (this.game) {
      try {
        this.game = await this.api.request('PATCH', `games/${this.game.id}`, {
          col_idx,
          row_idx,
        });
      } catch (e) {
        const errors = e as ErrorResponse;
        errors.forEach((err) => {
          this.toast.show(err.detail, 'error');
        });
      }
    } else {
      this.toast.show('no game to update!', 'error');
    }
  }

  get board(): BoardMatrix {
    const boardMatrix: BoardMatrix = Array.from({ length: 3 }, () =>
      Array(3).fill(null)
    );
    if (this.game) {
      this.game.moves.forEach((move: MoveResponse) => {
        boardMatrix[move.row_idx][move.col_idx] = move.player;
      });
    }
    return boardMatrix;
  }
}

type BoardMatrix = (Player | null)[][];

// Don't remove this declaration: this is what enables TypeScript to resolve
// this service using `Owner.lookup('service:game')`, as well
// as to check when you pass the service name as an argument to the decorator,
// like `@service('game') declare altName: GameService;`.
declare module '@ember/service' {
  interface Registry {
    game: GameService;
  }
}
