class CreateBookReadRsvps < ActiveRecord::Migration[7.1]
  def change
    create_table :book_read_rsvps do |t|
      t.references :book_read, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :book_read_rsvps, [ :book_read_id, :user_id ], unique: true
  end
end
