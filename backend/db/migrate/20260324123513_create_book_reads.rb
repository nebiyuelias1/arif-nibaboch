class CreateBookReads < ActiveRecord::Migration[8.0]
  def change
    create_table :book_reads do |t|
      t.references :book, null: false, foreign_key: true
      t.references :book_club, null: false, foreign_key: true
      t.date :start_date
      t.date :end_date
      t.integer :status

      t.timestamps
    end
  end
end
