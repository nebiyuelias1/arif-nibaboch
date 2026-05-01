class CreatePolls < ActiveRecord::Migration[8.0]
  def change
    create_table :polls do |t|
      t.references :book_read, null: false, foreign_key: true
      t.string :text, null: false
      t.text :description
      t.datetime :end_date

      t.timestamps
    end
  end
end
