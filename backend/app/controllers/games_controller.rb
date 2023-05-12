class GamesController < ApplicationController
  # Set user before executing any action in the controller
  before_action :set_user

  # GET /games
  # Returns the current active game or a 'No active game found' message with a 404 status
  def index
    game = Game.find_by(user: @user, finished: false)
    if game
      render json: game.game_with_state
    else
      render json: { message: 'No active game found' }, status: :not_found
    end
  end

  # POST /games
  # Creates a new game and marks all previous games for the user as finished
  def create
    Game.mark_all_finished_for_user(@user)

    game = Game.new(user: @user, finished: false, selected_symbol: game_params[:selected_symbol])

    if game.save
      render json: game.game_with_state, status: :created
    else
      render json: { errors: game.errors }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /games/:id
  # Updates the game with a user move and processes the bot move
  def update
    game = Game.find_by(id: params[:id])
    return render json: { message: 'Game not found' }, status: :not_found if game.nil?

    return render json: { message: 'Game finished' }, status: :unprocessable_entity if game.finished

    existing_move = Move.find_by(game_id: game.id, col_idx: game_params[:col_idx], row_idx: game_params[:row_idx])
    return render json: { message: 'Requested position is already occupied' }, status: :unprocessable_entity if existing_move

    col_idx = game_params[:col_idx]
    row_idx = game_params[:row_idx]

    user_move = Move.new(game: game, col_idx: col_idx, row_idx: row_idx, player: 'user')

    if user_move.save
      return render json: game.game_with_state if game.winner
      result = game.process_bot_move
      render json: result, status: :ok
    else
      render json: { errors: user_move.errors }, status: :unprocessable_entity
    end
  end

  private

  # Sets the user from the request header or generates a new UUID if not present
  def set_user
    @user = request.headers['X-TTT-User-ID']
    @user = SecureRandom.uuid unless @user.present?
    response.headers['X-TTT-User-ID'] = @user
  end

  # Permits the required parameters for game updates
  def game_params
    params.permit(:selected_symbol, :col_idx, :row_idx)
  end
end
