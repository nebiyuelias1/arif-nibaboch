# Full Text Search Implementation

This document describes the full text search implementation for books using SQLite FTS5 (Full-Text Search).

## Overview

The full text search allows users to search for books across multiple fields:
- `title` - The main title of the book
- `title_romanized` - Romanized version of the title (for non-Latin scripts)
- `title_en` - English translation of the title
- `author` - The author's name
- `description` - The book description

## Architecture

### Database Layer

The implementation uses SQLite's FTS5 (Full-Text Search version 5) virtual table, which provides:
- Fast full-text search capabilities
- Relevance ranking of search results
- Support for Unicode text (including Amharic and other scripts)
- Tokenization and stemming

### Virtual Table Structure

A virtual table `books_fts` is created with the following columns:
- `title` - Indexed for full-text search
- `title_romanized` - Indexed for full-text search
- `title_en` - Indexed for full-text search
- `author` - Indexed for full-text search
- `description` - Indexed for full-text search
- `book_id` - UNINDEXED (used for joining with the main books table)

### Synchronization Triggers

Three triggers keep the FTS table synchronized with the books table:
1. `books_fts_insert` - Adds entries when a new book is created
2. `books_fts_update` - Updates entries when a book is modified
3. `books_fts_delete` - Removes entries when a book is deleted

## Usage

### In Models

The `Book` model provides a `search` scope:

```ruby
# Search for books
Book.search("Gatsby")
Book.search("dystopian novel")
Book.search("የአበባው") # Amharic text
```

The search:
- Returns an empty relation if the query is blank
- Sanitizes the query to prevent FTS5 syntax errors
- Orders results by relevance (using FTS5's built-in ranking)
- Searches across all indexed fields simultaneously

### In Controllers

```ruby
def search
  query = params[:query]
  @books = if query.present?
             Book.search(query).limit(10)
  else
             []
  end

  render layout: false
end
```

## Migration

The migration file `20260204005400_add_full_text_search_to_books.rb`:
1. Creates the FTS5 virtual table
2. Populates it with existing book data
3. Sets up triggers for automatic synchronization

To apply the migration:
```bash
rails db:migrate
```

To rollback:
```bash
rails db:rollback
```

## Testing

Test the search functionality:

```ruby
# Test searching by title
Book.search("Gatsby")

# Test searching by author
Book.search("Orwell")

# Test searching by description
Book.search("dystopian")

# Test with Amharic text
Book.search("የአበባው")
```

## Performance Considerations

- FTS5 provides O(log n) search performance
- Results are automatically ranked by relevance
- The virtual table is automatically synchronized with the books table
- No manual index maintenance required

## Security

The implementation includes query sanitization to:
- Remove potentially dangerous characters
- Prevent FTS5 syntax errors
- Support Unicode characters (including Amharic)

## Limitations

- FTS5 is SQLite-specific (would need adaptation for PostgreSQL or MySQL)
- Query syntax is simplified for safety (no advanced FTS5 operators exposed)
- Maximum relevance ranking is determined by FTS5's default BM25 algorithm

## Future Improvements

Possible enhancements:
- Add support for phrase queries (e.g., "exact phrase")
- Implement query suggestions/autocomplete
- Add search highlighting in results
- Support for synonym expansion
- Language-specific tokenizers for better Amharic support
