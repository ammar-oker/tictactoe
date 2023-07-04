import Component from '@glimmer/component';

interface GameSymbolArgs {
  player: 'user' | 'bot' | null;
  selectedSymbol: 'x' | 'o';
}

export default class GameSymbolComponent extends Component<GameSymbolArgs> {
  get symbol(): 'x' | 'o' {
    const { player, selectedSymbol } = this.args;
    if (!player) return selectedSymbol;
    return player === 'user'
      ? selectedSymbol
      : selectedSymbol === 'x'
      ? 'o'
      : 'x';
  }

  get isBlank(): boolean {
    return !this.args.player;
  }
}
