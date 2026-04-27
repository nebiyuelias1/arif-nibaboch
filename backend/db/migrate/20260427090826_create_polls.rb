class CreatePolls < ActiveRecord::Migration[8.0]
  def change
    create_table :polls do |t|
      t.references :book_reads, null: false, foreign_key: true
      t.text :title
      t.text :description
      t.datetime :deadline

      t.timestamps
    end
  end
end
