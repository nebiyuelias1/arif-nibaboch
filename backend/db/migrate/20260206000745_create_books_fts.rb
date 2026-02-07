class CreateBooksFts < ActiveRecord::Migration[8.0]
  def change
    create_virtual_table :books_fts, :fts5, [
      'title',
      'author',
      'description',
      'publisher',
      'title_en',
      'title_romanized',
      'author_romanized',
      'content=books',
      'content_rowid=id'
    ]
  end
end
