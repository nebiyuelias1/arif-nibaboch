require "administrate/base_dashboard"

class PollDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    book_read: Field::BelongsTo,
    poll_options: Field::HasMany,
    poll_votes: Field::HasMany,
    text: Field::Text,
    end_date: Field::DateTime,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    book_read
    text
    end_date
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    book_read
    text
    end_date
    poll_options
    poll_votes
    created_at
    updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[
    book_read
    text
    end_date
    poll_options
  ].freeze

  COLLECTION_FILTERS = {}.freeze
end
