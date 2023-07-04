class Game < ApplicationRecord
  # Associations
  has_many :moves, dependent: :destroy

  # Validations
  validates :selected_symbol, inclusion: { in: %w[x o], message: "must be 'x' or 'o'" }

  # The bot will make the most optimal available move.
  def process_bot_move
    return if available_moves(board_matrix).empty?

    best_score = -Float::INFINITY
    best_move = nil

    available_moves(board_matrix).each do |move|
      # Create a temporary move to evaluate its score
      temp_board = board_matrix
      temp_board[move[:row_idx]][move[:col_idx]] = 'bot'
      score = minimax(temp_board, 0, false)

      if score > best_score
        best_score = score
        best_move = move
      end
    end

    # Perform the best move
    Move.create(game: self, col_idx: best_move[:col_idx], row_idx: best_move[:row_idx], player: 'bot') unless best_move.nil?
  end


  # This is the Minimax algorithm. It's a recursive function that's used to determine the best move for the bot.
  def minimax(board, depth, is_maximizing)
    # Check if the game has ended (i.e., if there's a winner or if the board is full)
    winner = check_winner(board)
    # If bot wins, return 1; if user wins, return -1; if it's a draw, return 0.
    if winner == 'bot'
      return 1
    elsif winner == 'user'
      return -1
    elsif board.flatten.compact.size == 9
      return 0
    end

    if is_maximizing # If the bot is maximizing (i.e., it's the bot turn)
      best_score = -Float::INFINITY
      # Iterate over all possible moves
      available_moves(board).each do |move|
        temp_board = Marshal.load(Marshal.dump(board)) # Create a deep copy of the board
        temp_board[move[:row_idx]][move[:col_idx]] = 'bot' # Try this move for the bot
        score = minimax(temp_board, depth + 1, false) # Call minimax recursively with the new board state
        best_score = [score, best_score].max # Pick the move with the highest score
      end
      best_score
    else # If the bot is minimizing (i.e., it's the user's turn)
      best_score = Float::INFINITY
      # Iterate over all possible moves
      available_moves(board).each do |move|
        temp_board = Marshal.load(Marshal.dump(board)) # Create a deep copy of the board
        temp_board[move[:row_idx]][move[:col_idx]] = 'user' # Try this move for the user
        score = minimax(temp_board, depth + 1, true) # Call minimax recursively with the new board state
        best_score = [score, best_score].min # Pick the move with the lowest score
      end
      best_score
    end
  end


  def available_moves(board)
    available_moves = []
    board.each_with_index do |row, row_idx|
      row.each_with_index do |cell, col_idx|
        if cell.nil?
          available_moves << { row_idx: row_idx, col_idx: col_idx }
        end
      end
    end
    available_moves
  end


  # Determines if the game has finished
  def finished
    check_winner(board_matrix).present? || available_moves(board_matrix).empty?
  end

  def winner
    check_winner(board_matrix)
  end

  # Returns the game state in a form of 2D matrix
  def board_matrix
    matrix = Array.new(3) { Array.new(3, nil) }
    moves.each do |move|
      matrix[move.row_idx][move.col_idx] = move.player
    end
    matrix
  end

  # Determines the winner of the game, if any
  def check_winner(board)
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

    winning_combinations.each do |combination|
      players = combination.map { |row_idx, col_idx| board[row_idx][col_idx] }.uniq

      # If all positions in a winning combination are occupied by the same player, return the winner
      if players.length == 1 && players.first.present?
        return players.first
      end
    end

    nil
  end
end
