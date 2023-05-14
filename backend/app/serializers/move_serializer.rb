class MoveSerializer < ActiveModel::Serializer
  attributes :id, :col_idx, :row_idx, :player
  belongs_to :game
end
