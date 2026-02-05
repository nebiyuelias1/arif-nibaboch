# Books FTS Migration - User Guide

## Overview

This migration creates a FTS5 (Full-Text Search 5) virtual table for implementing full-text search functionality on the books database.

### Migration Details
- **File**: `db/migrate/20260205055632_create_books_fts.rb`
- **Status**: ✓ Validated and ready to execute
- **Database**: SQLite3
- **Rails Version**: 8.0+

## What This Migration Does

### Creates Virtual Table
Creates a `books_fts` FTS5 virtual table with columns:
- title
- author
- description
- publisher
- title_en
- title_romanized
- author_romanized

### Automatic Synchronization
Three database triggers keep the FTS table in sync with the books table:
- **INSERT**: Automatically indexes new books
- **UPDATE**: Re-indexes modified books
- **DELETE**: Removes deleted books from index

### Initial Population
Populates the FTS table with existing books from the database

## Running the Migration

### Standard Execution
```bash
cd backend
bundle install
bin/rails db:migrate
```

### With SSL Certificate Issues (Docker)
If you encounter SSL certificate errors during bundle install:

```bash
# Option 1: Configure bundler to skip SSL verification
bundle config set --global ssl_verify_mode 0
bundle install

# Option 2: Or set via environment variable
SSL_VERIFY_MODE=none bundle install

# Then run migration as normal
bin/rails db:migrate
```

### Verify Success
```bash
# Check if table exists
bin/rails runner 'puts "books_fts table: #{ActiveRecord::Base.connection.tables.include?("books_fts")}"'

# Or use SQLite directly
sqlite3 storage/development.sqlite3
> .tables   # Should show books_fts
> .quit
```

## Using Full-Text Search

### In Rails Console
```ruby
# Simple FTS query
results = Book.connection.execute("SELECT * FROM books_fts WHERE books_fts MATCH 'ruby programming'")

# Get book IDs and fetch full records
book_ids = Book.connection.execute("SELECT rowid FROM books_fts WHERE books_fts MATCH 'search_term'").map { |row| row['rowid'] }
books = Book.where(id: book_ids)
```

### In Model (add to Book model)
```ruby
class Book < ApplicationRecord
  scope :search, ->(query) {
    ids = connection.execute(
      "SELECT rowid FROM books_fts WHERE books_fts MATCH ?",
      [query]
    ).map { |row| row['rowid'] }
    where(id: ids)
  }
end

# Usage
Book.search('ruby programming')
```

## Troubleshooting

### SSL Certificate Errors
**Error**: "Could not verify the SSL certificate for https://rubygems.org/"

**Solutions**:
1. Use the bundle config workaround above
2. Check if your organization uses a proxy with self-signed certificates
3. Configure Docker to use your organization's CA certificate

### FTS Table Not Found After Migration
```bash
# Verify migration ran
bin/rails db:migrate:status | grep books_fts

# Check database directly
sqlite3 storage/development.sqlite3 ".schema books_fts"
```

### Rollback
```bash
bin/rails db:rollback
```

This safely removes:
- books_fts_insert trigger
- books_fts_delete trigger
- books_fts_update trigger
- books_fts virtual table

## SQL Verification (Advanced)

```sql
-- Check FTS table exists
SELECT name FROM sqlite_master WHERE type='table' AND name='books_fts';

-- List all triggers
SELECT name, sql FROM sqlite_master WHERE type='trigger' AND (tbl_name='books' OR tbl_name='books_fts');

-- Test FTS query (requires books to exist)
SELECT id, title, author FROM books_fts WHERE books_fts MATCH 'search_term' LIMIT 10;

-- Check FTS ranking (most relevant first)
SELECT id, title, author, rank FROM (
  SELECT id, title, author, rank FROM books_fts 
  WHERE books_fts MATCH 'search_term'
  ORDER BY rank
) LIMIT 10;
```

## Performance Notes

- FTS5 is optimized for text search and provides better performance than LIKE queries
- Initial population uses existing book data
- Triggers maintain the index automatically
- Search queries run directly against the virtual table for minimal overhead

## Compatibility

- **Rails**: 8.0+
- **Ruby**: 3.0+
- **Database**: SQLite3 with FTS5 enabled
- **Migration Style**: Reversible (supports rollback)

## References

- [SQLite FTS5 Documentation](https://www.sqlite.org/fts5.html)
- [Rails Migrations Guide](https://guides.rubyonrails.org/active_record_migrations.html)
- [Rails FTS Support](https://guides.rubyonrails.org/active_record_basics.html#other-helpers)
