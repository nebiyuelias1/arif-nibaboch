class CreateBookClubs < ActiveRecord::Migration[8.0]
  def change
    create_table :book_clubs do |t|
      t.string :name
      t.text :description
      t.boolean :is_private, default: false
      t.references :owner, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
