require "test_helper"

class GamesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @game = Game.create(selected_symbol: 'x')
  end

  # `index` endpoint tests - start
  test "should return not found if no active game" do
    get game_url(435)
    assert_response :not_found
  end

  test "should return active game state" do
    get game_url(@game.id)
    assert_response :success
    assert_equal @game.id, response.parsed_body['id'].to_i
  end

  # `index` endpoint tests - end

  # `create` endpoint tests - start
  test "should create a new game with a valid selected_symbol" do
    post games_url, params: { selected_symbol: 'x' }
    assert_response :created
    assert_equal 'x', Game.last.selected_symbol
  end

  test "should not create a new game with an invalid selected_symbol" do
    user_id = SecureRandom.uuid
    post games_url, params: { selected_symbol: 'invalid' }, headers: { 'X-TTT-User-ID': user_id }
    assert_response :unprocessable_entity
    assert_equal 422, response.status
    assert_not_nil response.parsed_body['errors']
  end
  # `create` endpoint tests - end

  # `update` endpoint test - start
  test "should return not found when updating a non-existent game" do
    patch game_url(-1)
    assert_response :not_found
  end

  test "should not allow move to an already occupied position" do
    @game.moves.create(col_idx: 0, row_idx: 0, player: 'user')
    patch game_url(@game.id), params: { col_idx: 0, row_idx: 0 }
    assert_response :unprocessable_entity
  end

  test "should update game with successful user move when no winner and available moves left" do
    game = Game.create(selected_symbol: 'x')
    patch game_url(game.id), params: { col_idx: 0, row_idx: 0 }
    assert_response :ok
  end

  test "should update game with successful user move leading to a win" do
    game = Game.create(selected_symbol: 'x')
    game.moves.create(col_idx: 0, row_idx: 0, player: 'user') # 1
    game.moves.create(col_idx: 0, row_idx: 1, player: 'bot')  # 2
    game.moves.create(col_idx: 1, row_idx: 0, player: 'user') # 3
    game.moves.create(col_idx: 1, row_idx: 1, player: 'bot')  # 4

    # The previous moves will result the following board state
    #
    # X | O | ?
    # ---------
    # X | O | ?
    # ---------
    # ? | ? | ?

    patch game_url(game.id), params: { col_idx: 2, row_idx: 0 }
    assert_response :ok
    winner = response.parsed_body['winner']
    assert_equal 'user', winner
  end

  test "should update game with successful user move resulting in a draw" do
    game = Game.create(selected_symbol: 'x')
    game.moves.create(col_idx: 0, row_idx: 0, player: 'user') # 1
    game.moves.create(col_idx: 1, row_idx: 1, player: 'bot')  # 2
    game.moves.create(col_idx: 0, row_idx: 1, player: 'user') # 3
    game.moves.create(col_idx: 0, row_idx: 2, player: 'bot')  # 4
    game.moves.create(col_idx: 2, row_idx: 0, player: 'user') # 5
    game.moves.create(col_idx: 1, row_idx: 0, player: 'bot')  # 6
    game.moves.create(col_idx: 1, row_idx: 2, player: 'user') # 7
    game.moves.create(col_idx: 2, row_idx: 1, player: 'bot')  # 8

    # The previous moves will result the following board state
    #
    # X | X | O
    # ---------
    # O | O | X
    # ---------
    # X | O | ?

    # The user move will result in a draw.
    patch game_url(game.id), params: { col_idx: 2, row_idx: 2 }
    assert_response :ok
    assert_nil response.parsed_body['winner']
  end
  # `update` endpoint test - end
end
