class Book < ApplicationRecord
  validates :title, presence: true
  validates :author, presence: true

  has_many :book_tags, dependent: :destroy
  has_many :tags, through: :book_tags
  has_many :ratings, dependent: :destroy

  # Full-text search scope using SQLite FTS5
  scope :search, ->(query) {
    return none if query.blank?

    # Sanitize the query for FTS5 - keep alphanumeric and spaces only
    # FTS5 tokenizes on punctuation, so we remove it to avoid syntax errors
    # Including support for: Latin, Cyrillic, Arabic, Ethiopic, CJK, and other scripts
    sanitized_query = query.gsub(/[^\p{L}\p{N}\s]/, " ").strip
    return none if sanitized_query.blank?

    # Use FTS5 MATCH for full-text search across all indexed fields
    joins("INNER JOIN books_fts ON books.id = books_fts.book_id")
      .where("books_fts MATCH ?", sanitized_query)
      .order("books_fts.rank")
  }

  def average_rating
    ratings.average(:score)&.round(1) || 0
  end

  def user_rating(user)
    ratings.find_by(user: user)
  end
end
