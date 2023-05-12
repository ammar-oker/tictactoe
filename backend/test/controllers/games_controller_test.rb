require "test_helper"

class GamesControllerTest < ActionDispatch::IntegrationTest
  # `index` endpoint tests - start
  test "should return not found if no active game" do
    user_id = SecureRandom.uuid
    get games_url, headers: { 'X-TTT-User-ID': user_id }
    assert_response :not_found
    assert_equal "No active game found", response.parsed_body["message"]
  end

  test "should return active game state" do
    user_id = SecureRandom.uuid
    game = Game.create(user: user_id, finished: false, selected_symbol: 'x')
    get games_url, headers: { 'X-TTT-User-ID': user_id }
    assert_response :success
    assert_equal game.id, response.parsed_body["game"]["id"]
  end

  test "should set new user ID in response header if not provided in request" do
    get games_url
    assert_response :not_found
    assert response.headers['X-TTT-User-ID'].present?
  end

  test "should use provided user ID in response header" do
    user_id = SecureRandom.uuid
    get games_url, headers: { 'X-TTT-User-ID': user_id }
    puts response.headers.inspect
    assert_response :not_found
    assert_equal user_id, response.headers['X-TTT-User-ID']
  end
  # `index` endpoint tests - end

  # `create` endpoint tests - start
  test "should create a new game with a valid selected_symbol" do
    user_id = SecureRandom.uuid
    post games_url, params: { selected_symbol: 'x' }, headers: { 'X-TTT-User-ID': user_id }
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


  test "should mark all previous unfinished games as finished when creating a new game" do
    user_id = SecureRandom.uuid
    unfinished_game = Game.create(user: user_id, finished: false, selected_symbol: 'x')

    post games_url, params: { selected_symbol: 'o' }, headers: { 'X-TTT-User-ID': user_id }
    assert_response :created
    unfinished_game.reload
    assert_equal true, unfinished_game.finished
  end
  # `create` endpoint tests - end

  # `update` endpoint test - start
  test "should return not found when updating a non-existent game" do
    user_id = SecureRandom.uuid
    patch game_url(-1), params: { col_idx: 0, row_idx: 0 }, headers: { 'X-TTT-User-ID': user_id }
    assert_response :not_found
    assert_not_nil response.parsed_body['message']
  end

  test "should not update a finished game" do
    user_id = SecureRandom.uuid
    game = Game.create(user: user_id, finished: true, selected_symbol: 'x')
    patch game_url(game.id), params: { col_idx: 0, row_idx: 0 }, headers: { 'X-TTT-User-ID': user_id }
    assert_response :unprocessable_entity
    assert_not_nil response.parsed_body['message']
  end

  test "should not allow move to an already occupied position" do
    user_id = SecureRandom.uuid
    game = Game.create(user: user_id, finished: false, selected_symbol: 'x')
    Move.create(game: game, col_idx: 0, row_idx: 0, player: 'user')
    patch game_url(game.id), params: { col_idx: 0, row_idx: 0 }, headers: { 'X-TTT-User-ID': user_id }
    assert_response :unprocessable_entity
    assert_not_nil response.parsed_body['message']
  end

  test "should update game with successful user move when no winner and available moves left" do
    user_id = SecureRandom.uuid
    game = Game.create(user: user_id, finished: false, selected_symbol: 'x')
    patch game_url(game.id), params: { col_idx: 0, row_idx: 0 }, headers: { 'X-TTT-User-ID': user_id }
    assert_response :ok
    assert_nil response.parsed_body['winner']
    assert_nil response.parsed_body['message']
    assert_not_nil response.parsed_body['game']
  end

  test "should update game with successful user move leading to a win" do
    user_id = SecureRandom.uuid
    game = Game.create(user: user_id, finished: false, selected_symbol: 'x')
    Move.create(game: game, col_idx: 0, row_idx: 0, player: 'user') # 1
    Move.create(game: game, col_idx: 0, row_idx: 1, player: 'bot')  # 2
    Move.create(game: game, col_idx: 1, row_idx: 0, player: 'user') # 3
    Move.create(game: game, col_idx: 1, row_idx: 1, player: 'bot')  # 4

    # The previous moves will result the following board state
    #
    # X | O | ?
    # ---------
    # X | O | ?
    # ---------
    # ? | ? | ?

    patch game_url(game.id), params: { col_idx: 2, row_idx: 0 }, headers: { 'X-TTT-User-ID': user_id }
    assert_response :ok
    assert_equal 'user', response.parsed_body['winner']
  end

  test "should update game with successful user move resulting in a draw" do
    user_id = SecureRandom.uuid
    game = Game.create(user: user_id, finished: false, selected_symbol: 'x')
    Move.create(game: game, col_idx: 0, row_idx: 0, player: 'user') # 1
    Move.create(game: game, col_idx: 1, row_idx: 1, player: 'bot')  # 2
    Move.create(game: game, col_idx: 0, row_idx: 1, player: 'user') # 3
    Move.create(game: game, col_idx: 0, row_idx: 2, player: 'bot')  # 4
    Move.create(game: game, col_idx: 2, row_idx: 0, player: 'user') # 5
    Move.create(game: game, col_idx: 1, row_idx: 0, player: 'bot')  # 6
    Move.create(game: game, col_idx: 1, row_idx: 2, player: 'user') # 7
    Move.create(game: game, col_idx: 2, row_idx: 1, player: 'bot')  # 8

    # The previous moves will result the following board state
    #
    # X | X | O
    # ---------
    # O | O | X
    # ---------
    # X | O | ?

    # The user move will result in a draw.
    patch game_url(game.id), params: { col_idx: 2, row_idx: 2 }, headers: { 'X-TTT-User-ID': user_id }
    assert_response :ok
    assert_nil response.parsed_body['winner']
  end
  # `update` endpoint test - end
end
