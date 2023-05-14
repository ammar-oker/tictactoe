require "test_helper"

class MoveTest < ActiveSupport::TestCase
  def setup
    @game = Game.create(selected_symbol: 'x')
  end

  test 'valid move' do
    move = Move.new(game: @game, col_idx: 1, row_idx: 1, player: 'user')
    assert move.valid?
  end

  test 'invalid without game' do
    move = Move.new(col_idx: 1, row_idx: 1, player: 'user')
    assert_not move.valid?
    assert_not_empty move.errors[:game]
  end

  test 'invalid without col_idx' do
    move = Move.new(game: @game, row_idx: 1, player: 'user')
    assert_not move.valid?
    assert_not_empty move.errors[:col_idx]
  end

  test 'invalid without row_idx' do
    move = Move.new(game: @game, col_idx: 1, player: 'user')
    assert_not move.valid?
    assert_not_empty move.errors[:row_idx]
  end

  test 'invalid without player' do
    move = Move.new(game: @game, col_idx: 1, row_idx: 1)
    assert_not move.valid?
    assert_not_empty move.errors[:player]
  end

  test 'invalid col_idx out of range' do
    move = Move.new(game: @game, col_idx: 3, row_idx: 1, player: 'user')
    assert_not move.valid?
    assert_not_empty move.errors[:col_idx]
  end

  test 'invalid row_idx out of range' do
    move = Move.new(game: @game, col_idx: 1, row_idx: 3, player: 'user')
    assert_not move.valid?
    assert_not_empty move.errors[:row_idx]
  end

  test 'invalid player value' do
    move = Move.new(game: @game, col_idx: 1, row_idx: 1, player: 'invalid_player')
    assert_not move.valid?
    assert_not_empty move.errors[:player]
  end

  test 'belongs to game' do
    move = Move.create(game: @game, col_idx: 1, row_idx: 1, player: 'user')
    assert_equal @game, move.game
  end
end
