class Initial < ActiveRecord::Migration[7.0]
  def change
    create_table :games do |t|
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.string :selected_symbol
    end

    create_table :moves do |t|
      t.integer :col_idx
      t.integer :row_idx
      t.string :player
      t.integer :game_id, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.index [:game_id], name: "index_moves_on_game_id"
    end

    add_foreign_key :moves, :games
  end
end
