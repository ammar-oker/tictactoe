import Component from '@glimmer/component';
import { service } from '@ember/service';
import ApiService from 'frontend/services/api';

export default class LoadingComponent extends Component {
  @service('api') api: ApiService;
}
