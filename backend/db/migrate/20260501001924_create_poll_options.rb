class CreatePollOptions < ActiveRecord::Migration[8.0]
  def change
    create_table :poll_options do |t|
      t.references :poll, null: false, foreign_key: true
      t.string :content, null: false
      t.references :book, null: true, foreign_key: true

      t.timestamps
    end
  end
end
