require "administrate/base_dashboard"

class PollOptionDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    poll: Field::BelongsTo,
    poll_votes: Field::HasMany,
    book: Field::BelongsTo,
    content: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    poll
    content
    book
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    poll
    book
    content
    poll_votes
    created_at
    updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[
    poll
    book
    content
  ].freeze

  COLLECTION_FILTERS = {}.freeze
end
