import Component from '@glimmer/component';
import { service } from '@ember/service';
import ToastService from 'frontend/services/toast';
import fade from 'ember-animated/transitions/fade';

export default class ToastDisplayComponent extends Component {
  @service('toast') toast: ToastService;
  transition = fade;
}
