class AddFullTextSearchToBooks < ActiveRecord::Migration[8.0]
  def up
    # Create a virtual FTS5 table for full-text search
    execute <<-SQL
      CREATE VIRTUAL TABLE books_fts USING fts5(
        title,
        title_romanized,
        title_en,
        author,
        description,
        book_id UNINDEXED,
        content='books',
        content_rowid='id'
      );
    SQL

    # Populate the FTS table with existing books
    execute <<-SQL
      INSERT INTO books_fts(book_id, title, title_romanized, title_en, author, description, rowid)
      SELECT id, title, title_romanized, title_en, author, description, id
      FROM books;
    SQL

    # Create triggers to keep the FTS table in sync with the books table
    
    # Trigger for INSERT
    execute <<-SQL
      CREATE TRIGGER books_fts_insert AFTER INSERT ON books BEGIN
        INSERT INTO books_fts(book_id, title, title_romanized, title_en, author, description, rowid)
        VALUES (new.id, new.title, new.title_romanized, new.title_en, new.author, new.description, new.id);
      END;
    SQL

    # Trigger for UPDATE
    execute <<-SQL
      CREATE TRIGGER books_fts_update AFTER UPDATE ON books BEGIN
        UPDATE books_fts
        SET title = new.title,
            title_romanized = new.title_romanized,
            title_en = new.title_en,
            author = new.author,
            description = new.description
        WHERE rowid = new.id;
      END;
    SQL

    # Trigger for DELETE
    execute <<-SQL
      CREATE TRIGGER books_fts_delete AFTER DELETE ON books BEGIN
        DELETE FROM books_fts WHERE rowid = old.id;
      END;
    SQL
  end

  def down
    execute "DROP TRIGGER IF EXISTS books_fts_delete"
    execute "DROP TRIGGER IF EXISTS books_fts_update"
    execute "DROP TRIGGER IF EXISTS books_fts_insert"
    execute "DROP TABLE IF EXISTS books_fts"
  end
end
