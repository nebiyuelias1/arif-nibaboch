class CreateReviewLikes < ActiveRecord::Migration[8.0]
  def change
    create_table :review_likes do |t|
      t.references :review, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :review_likes, [ :review_id, :user_id ], unique: true
  end
end
