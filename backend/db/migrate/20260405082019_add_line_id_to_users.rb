class AddLineIdToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :line_id, :string
    add_index :users, :line_id, unique: true
  end
end
