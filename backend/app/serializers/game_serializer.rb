class GameSerializer < ActiveModel::Serializer
  attributes  :id, :finished, :selected_symbol, :winner
  has_many :moves
end
