class AddLikesCountToReviews < ActiveRecord::Migration[8.0]
  def change
    add_column :reviews, :review_likes_count, :integer, default: 0, null: false
  end
end
