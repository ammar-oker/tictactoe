class Game < ApplicationRecord
  # Associations
  has_many :moves, dependent: :destroy

  # Validations
  validates :user, presence: true
  validates :finished, inclusion: { in: [true, false], message: "must be `true` or `false`" }
  validates :selected_symbol, inclusion: { in: %w[x o], message: "must be 'x' or 'o'" }

  # Marks all games for a user as finished
  def self.mark_all_finished_for_user(user)
    where(user: user, finished: false).update_all(finished: true)
  end

  # Processes a bot move and updates the game state
  def process_bot_move
    available_moves = self.available_moves
    if available_moves.empty?
      update(finished: true)
      return self.game_with_state
    end
    bot_move = available_moves.sample
    Move.create(game: self, col_idx: bot_move[:col_idx], row_idx: bot_move[:row_idx], player: 'bot')
    self.game_with_state
  end

  # Returns the game along with its state and winner
  def game_with_state
    game_state = Array.new(3) { Array.new(3, nil) }
    moves.each do |move|
      game_state[move.row_idx][move.col_idx] = move.player
    end

    { game: self, game_state: game_state, winner: self.winner }
  end

  # Returns the available moves for the current game
  def available_moves
    taken_moves = moves.pluck(:col_idx, :row_idx)
    all_moves = (0..2).flat_map { |row| (0..2).map { |col| { col_idx: col, row_idx: row } } }
    all_moves - taken_moves
  end

  # Determines the winner of the game, if any
  def winner
    winning_combinations = [
      # Horizontal
      [[0, 0], [0, 1], [0, 2]],
      [[1, 0], [1, 1], [1, 2]],
      [[2, 0], [2, 1], [2, 2]],
      # Vertical
      [[0, 0], [1, 0], [2, 0]],
      [[0, 1], [1, 1], [2, 1]],
      [[0, 2], [1, 2], [2, 2]],
      # Diagonal
      [[0, 0], [1, 1], [2, 2]],
      [[0, 2], [1, 1], [2, 0]]
    ]

    game_state = Array.new(3) { Array.new(3, nil) }
    moves.each do |move|
      game_state[move.row_idx][move.col_idx] = move.player
    end

    winning_combinations.each do |combination|
      players = combination.map { |row_idx, col_idx| game_state[row_idx][col_idx] }.uniq

      # If all positions in a winning combination are occupied by the same player, return the winner
      if players.length == 1 && players.first.present?
        return players.first
      end
    end

    nil
  end
end
