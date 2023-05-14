import Service from '@ember/service';
import { tracked } from '@glimmer/tracking';
import ENV from 'frontend/config/environment';

export default class ApiService extends Service {
  baseURL = `${ENV.APP['API_HOST']}${ENV.APP['API_NAMESPACE']}`;
  @tracked loading = false;

  async request<T>(method: string, path: string, body?: any): Promise<T> {
    this.loading = true;
    const options = {
      method,
      headers: {
        'Content-Type': 'application/json',
        Accept: 'application/json',
      },
      body: body ? JSON.stringify(body) : undefined,
    };
    const response = await fetch(this.baseURL + path, options);
    this.loading = false;
    return this.handleErrors<T>(response);
  }

  private async handleErrors<T>(response: Response): Promise<T> {
    if (!response.ok) {
      const errorJson = await response.json();
      const errorDetails = errorJson.errors;
      let errorsToThrow = [];
      switch (response.status) {
        case 404:
        case 422:
          errorsToThrow = [...errorDetails];
          break;
        default:
          errorsToThrow.push({
            status: response.status,
            title: 'Unknown Error',
            detail: 'An unexpected error occurred',
          });
          break;
      }
      throw errorsToThrow;
    }
    return response.json();
  }
}

export type Player = 'user' | 'bot';

export interface MoveResponse {
  id: number;
  col_idx: number;
  row_idx: number;
  player: Player;
}

export interface GameResponse {
  id: number;
  finished: boolean;
  selected_symbol: 'x' | 'o';
  winner: Player | null;
  moves: MoveResponse[];
}

export type ErrorResponse = {
  status: string;
  title: string;
  detail: string;
  source?: string;
}[];

// Don't remove this declaration: this is what enables TypeScript to resolve
// this service using `Owner.lookup('service:api')`, as well
// as to check when you pass the service name as an argument to the decorator,
// like `@service('api') declare altName: ApiService;`.
declare module '@ember/service' {
  interface Registry {
    api: ApiService;
  }
}
