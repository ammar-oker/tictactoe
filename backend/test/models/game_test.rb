require "test_helper"

class GameTest < ActiveSupport::TestCase
  setup do
    @game = Game.create(selected_symbol: 'x')
  end


  test 'available_moves' do
    game = Game.create(selected_symbol: 'x')
    game.moves.create([{ col_idx: 0, row_idx: 0, player: 'user' }, col_idx: 0, row_idx: 1, player: 'bot'])
    expected_available_moves = [
      { col_idx: 0, row_idx: 2 },
      { col_idx: 1, row_idx: 0 },
      { col_idx: 1, row_idx: 1 },
      { col_idx: 1, row_idx: 2 },
      { col_idx: 2, row_idx: 0 },
      { col_idx: 2, row_idx: 1 },
      { col_idx: 2, row_idx: 2 },
    ]
    assert_equal expected_available_moves.to_set, game.available_moves(game.board_matrix).to_set
  end

  test 'winner' do
    # Test for no winner
    @game.moves.create([{ col_idx: 0, row_idx: 0, player: 'user' },
                        { col_idx: 0, row_idx: 1, player: 'bot' },
                        { col_idx: 0, row_idx: 2, player: 'user' },
                        { col_idx: 1, row_idx: 0, player: 'bot' },
                        { col_idx: 1, row_idx: 1, player: 'user' },
                        { col_idx: 1, row_idx: 2, player: 'bot' }])
    assert_nil @game.winner

    # Test for horizontal winner
    @game.moves.create(col_idx: 2, row_idx: 2, player: 'user')
    assert_equal 'user', @game.winner

    # Test for vertical winner
    game2 = Game.create(selected_symbol: 'x')
    game2.moves.create([{ col_idx: 0, row_idx: 0, player: 'user' },
                        { col_idx: 1, row_idx: 0, player: 'user' },
                        { col_idx: 2, row_idx: 0, player: 'user' }])
    assert_equal 'user', game2.winner

    # Test for diagonal winner (top-left to bottom-right)
    game3 = Game.create(selected_symbol: 'x')
    game3.moves.create([{ col_idx: 0, row_idx: 0, player: 'user' },
                        { col_idx: 1, row_idx: 1, player: 'user' },
                        { col_idx: 2, row_idx: 2, player: 'user' }])
    assert_equal 'user', game3.winner

    # Test for diagonal winner (top-right to bottom-left)
    game4 = Game.create(selected_symbol: 'x')
    game4.moves.create([{ col_idx: 0, row_idx: 2, player: 'user' },
                        { col_idx: 1, row_idx: 1, player: 'user' },
                        { col_idx: 2, row_idx: 0, player: 'user' }])
    assert_equal 'user', game4.winner
  end
end
