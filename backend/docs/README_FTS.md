# Books Full-Text Search

This feature adds full-text search capability to the books table using SQLite's FTS5 extension.

## What was added

- **Virtual Table**: `books_fts` - A FTS5 virtual table for efficient full-text searching
- **Indexed Columns**: title, author, description, publisher, title_en, title_romanized, author_romanized
- **Use rails hooks**: Use rails after_*_commit hooks to update the index automatically on create, update, and delete

## How to use

### Running the migration

```bash
bin/rails db:migrate
```

### Searching books

You can use FTS5 match queries to search across all indexed columns:

```ruby
# Search for books containing "ruby"
results = ActiveRecord::Base.connection.execute(
  "SELECT books.* FROM books_fts 
   JOIN books ON books_fts.rowid = books.id 
   WHERE books_fts MATCH 'ruby'"
)

# Search with multiple terms (AND)
results = ActiveRecord::Base.connection.execute(
  "SELECT books.* FROM books_fts 
   JOIN books ON books_fts.rowid = books.id 
   WHERE books_fts MATCH 'ruby programming'"
)

# Search with OR
results = ActiveRecord::Base.connection.execute(
  "SELECT books.* FROM books_fts 
   JOIN books ON books_fts.rowid = books.id 
   WHERE books_fts MATCH 'ruby OR python'"
)

# Search in specific column
results = ActiveRecord::Base.connection.execute(
  "SELECT books.* FROM books_fts 
   JOIN books ON books_fts.rowid = books.id 
   WHERE books_fts MATCH 'title:ruby'"
)
```

## Testing

Run the FTS tests:

```bash
bin/rails test test/models/books_test.rb
```

## Rollback

If needed, the migration can be rolled back:

```bash
bin/rails db:rollback
```

This will remove the virtual table and all triggers.

## Learn more

- [SQLite FTS5 Documentation](https://www.sqlite.org/fts5.html)
- [Rails SQLite3 FTS Discuss](https://discuss.rubyonrails.org/t/proposal-sqlite3-full-text-search-and-other-virtual-tables-do-not-dump-shadow-virtual-tables/86159)
- [How to add FTS to Rails Blog](https://za.chari.as/sqlite-full-text-search-in-rails)
- [Rails Migrations Guide](https://guides.rubyonrails.org/active_record_migrations.html)
