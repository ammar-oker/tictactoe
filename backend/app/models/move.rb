class Move < ApplicationRecord
  belongs_to :game
  validates :col_idx, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than: 3 }
  validates :row_idx, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than: 3 }
  validates :player, presence: true, inclusion: { in: %w[user bot] }
end
