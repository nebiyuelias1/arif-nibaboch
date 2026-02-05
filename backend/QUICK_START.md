# Books FTS Migration - Quick Start Guide

## TL;DR - Run the Migration in 3 Steps

### Step 1: Fix SSL Issue (if in Docker)
```bash
cd /home/runner/work/arif-nibaboch/arif-nibaboch/backend
bundle config set --global ssl_verify_mode 0
```

### Step 2: Install Gems & Run Migration
```bash
bundle install
bin/rails db:migrate
```

### Step 3: Verify
```bash
bin/rails runner 'puts "✓ FTS created: #{ActiveRecord::Base.connection.tables.include?("books_fts")}"'
```

---

## What This Migration Does

Creates a full-text search (FTS5) index for books with automatic sync via database triggers.

**Indexes these columns:**
- title
- author  
- description
- publisher
- title_en
- title_romanized
- author_romanized

---

## Use Full-Text Search

```ruby
# In Rails console or code
Book.connection.execute("SELECT * FROM books_fts WHERE books_fts MATCH 'ruby'")

# Or create a scope in Book model for easier access
scope :search, ->(query) {
  ids = connection.execute("SELECT rowid FROM books_fts WHERE books_fts MATCH ?", [query])
    .map { |row| row['rowid'] }
  where(id: ids)
}

# Usage: Book.search('ruby programming')
```

---

## Rollback If Needed
```bash
bin/rails db:rollback
```

---

## Problem: SSL Certificate Error

**Error:** "Could not verify the SSL certificate"

**Fix:**
```bash
bundle config set --global ssl_verify_mode 0
bundle install
```

**Note:** Only use this workaround in development! For production, configure proper SSL certificates with your IT/DevOps team.

---

## Verification

After running the migration:

```bash
# Check if table was created
bin/rails runner 'puts ActiveRecord::Base.connection.tables.include?("books_fts")'

# Or use SQLite directly
sqlite3 storage/development.sqlite3 ".tables" | grep books_fts

# Count indexed books
sqlite3 storage/development.sqlite3 "SELECT COUNT(*) FROM books_fts;"
```

---

## Migration Details

- **File:** `db/migrate/20260205055632_create_books_fts.rb`
- **Type:** Rails 8.0 Migration  
- **Database:** SQLite3
- **Status:** ✓ Validated & Ready
- **Reversible:** ✓ Supports rollback

---

## More Info

See `MIGRATION_GUIDE.md` for detailed usage, advanced FTS features, and troubleshooting.

See `MIGRATION_SETUP_REPORT.txt` for complete setup details and environmental information.
