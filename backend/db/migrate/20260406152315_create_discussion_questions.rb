class CreateDiscussionQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :discussion_questions do |t|
      t.references :book_read, null: false, foreign_key: true
      t.integer :status, default: 0
      t.text :content, null: false
      t.integer :position, default: 0

      t.timestamps
    end
  end
end
