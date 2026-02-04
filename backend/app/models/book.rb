class Book < ApplicationRecord
  validates :title, presence: true
  validates :author, presence: true

  has_many :book_tags, dependent: :destroy
  has_many :tags, through: :book_tags
  has_many :ratings, dependent: :destroy

  # Full-text search scope using SQLite FTS5
  scope :search, ->(query) {
    return none if query.blank?

    # Sanitize the query for FTS5
    sanitized_query = query.gsub(/[^a-zA-Z0-9\u0600-\u06FF\s]/, " ").strip
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
