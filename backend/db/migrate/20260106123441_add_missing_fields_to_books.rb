class AddMissingFieldsToBooks < ActiveRecord::Migration[8.0]
  def change
    add_column :books, :title_en, :string
    add_column :books, :title_romanized, :string
    add_column :books, :author_romanized, :string
    add_column :books, :page_count, :integer
  end
end
