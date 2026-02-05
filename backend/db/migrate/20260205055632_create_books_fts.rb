class CreateBooksFts < ActiveRecord::Migration[8.0]
  def change
    # Create FTS5 virtual table for full-text search on books
    # Using external content table for automatic synchronization
    reversible do |dir|
      dir.up do
        execute <<-SQL
          CREATE VIRTUAL TABLE books_fts USING fts5(
            title,
            author,
            description,
            publisher,
            title_en,
            title_romanized,
            author_romanized,
            content=books,
            content_rowid=id
          );
        SQL

        # Create triggers to keep FTS table in sync with books table
        execute <<-SQL
          CREATE TRIGGER books_fts_insert AFTER INSERT ON books BEGIN
            INSERT INTO books_fts(rowid, title, author, description, publisher, title_en, title_romanized, author_romanized)
            VALUES (new.id, new.title, new.author, new.description, new.publisher, new.title_en, new.title_romanized, new.author_romanized);
          END;
        SQL

        execute <<-SQL
          CREATE TRIGGER books_fts_delete AFTER DELETE ON books BEGIN
            DELETE FROM books_fts WHERE rowid = old.id;
          END;
        SQL

        execute <<-SQL
          CREATE TRIGGER books_fts_update AFTER UPDATE ON books BEGIN
            DELETE FROM books_fts WHERE rowid = old.id;
            INSERT INTO books_fts(rowid, title, author, description, publisher, title_en, title_romanized, author_romanized)
            VALUES (new.id, new.title, new.author, new.description, new.publisher, new.title_en, new.title_romanized, new.author_romanized);
          END;
        SQL

        # Populate the FTS table with existing data
        execute <<-SQL
          INSERT INTO books_fts(rowid, title, author, description, publisher, title_en, title_romanized, author_romanized)
          SELECT id, title, author, description, publisher, title_en, title_romanized, author_romanized
          FROM books;
        SQL
      end

      dir.down do
        execute "DROP TRIGGER IF EXISTS books_fts_insert;"
        execute "DROP TRIGGER IF EXISTS books_fts_delete;"
        execute "DROP TRIGGER IF EXISTS books_fts_update;"
        execute "DROP TABLE IF EXISTS books_fts;"
      end
    end
  end
end
