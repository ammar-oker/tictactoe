class GamesController < ApplicationController
  # GET /games/:user
  # Returns the active game for the current user,
  # or a 'No active game for this user.' message with a 404 status
  def show
    begin
      @game = Game.find(params[:id])
    render json: @game, status: :ok
    rescue ActiveRecord::RecordNotFound
      render_error(404, 'No active game for this user.')
    end
  end

  # POST /games
  # Creates a new game and marks all previous games for the user as finished
  def create
    @game = Game.new(selected_symbol: game_params[:selected_symbol])
    if @game.save
      render json: @game, status: :created
    else
      render_validation_errors(@game)
    end
  end


  # PATCH/PUT /games/:id
  # Updates the game with a user move and processes the bot move
  def update
    @game = Game.find_by(id: params[:id])
    return render_error(404, 'Game not found') if @game.nil?
    return render_error(422, 'Game finished') if @game.finished

    existing_move = Move.find_by(game_id: @game.id, col_idx: game_params[:col_idx], row_idx: game_params[:row_idx])
    return render_error(422, 'Requested position is already occupied') if existing_move

    col_idx = game_params[:col_idx]
    row_idx = game_params[:row_idx]

    user_move = @game.moves.new(game: @game, col_idx: col_idx, row_idx: row_idx, player: 'user')
    if user_move.save
      if @game.winner
        render json: GameSerializer.new(@game, include: [:moves]).serializable_hash
      else
        @game.process_bot_move
        @game.reload
        render json: GameSerializer.new(@game, include: [:moves]).serializable_hash, status: :ok
      end
    else
      render_validation_errors(user_move)
    end
  end


  private

  # Permits the required parameters for game updates
  def game_params
    params.permit(:selected_symbol, :col_idx, :row_idx)
  end
end
