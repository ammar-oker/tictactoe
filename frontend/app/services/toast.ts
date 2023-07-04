import Service from '@ember/service';
import { registerDestructor } from '@ember/destroyable';
import { tracked } from '@glimmer/tracking';

export default class ToastService extends Service {
  timeout = 3000;
  @tracked notifications: Notification[] = [];

  show(message: string, type: Notification['type'] = 'info') {
    const notification = {
      message: message,
      type: type,
      id: Date.now(),
    };
    this.notifications = [...this.notifications, notification];

    const timerId = setTimeout(() => {
      this.notifications = this.notifications.filter(
        (n) => n.id !== notification.id
      );
    }, this.timeout);
    registerDestructor(notification, () => clearTimeout(timerId));
  }
}

interface Notification {
  id: number;
  type: 'info' | 'error' | 'warning';
  message: string;
}

// Don't remove this declaration: this is what enables TypeScript to resolve
// this service using `Owner.lookup('service:toast')`, as well
// as to check when you pass the service name as an argument to the decorator,
// like `@service('toast') declare altName: ToastService;`.
declare module '@ember/service' {
  interface Registry {
    toast: ToastService;
  }
}
