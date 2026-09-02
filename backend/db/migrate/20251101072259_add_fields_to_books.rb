class AddFieldsToBooks < ActiveRecord::Migration[8.0]
  def change
    add_column :books, :language, :string, default: "am"
    add_column :books, :cover_image, :string
    add_column :books, :publisher, :string
    add_column :books, :isbn, :string
    add_column :books, :average_rating, :float, default: 0.0, null: false
    add_column :books, :reviews_count, :integer, default: 0, null: false
  end
end
