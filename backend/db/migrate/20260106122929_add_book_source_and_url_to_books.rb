class AddBookSourceAndUrlToBooks < ActiveRecord::Migration[8.0]
  def change
    add_column :books, :source, :string
    add_column :books, :source_url, :string
  end
end
