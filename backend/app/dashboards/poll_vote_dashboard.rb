require "administrate/base_dashboard"

class PollVoteDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    poll_option: Field::BelongsTo,
    poll: Field::HasOne,
    user: Field::BelongsTo,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    poll_option
    poll
    user
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    poll_option
    poll
    user
    created_at
    updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[
    poll_option
    user
  ].freeze

  COLLECTION_FILTERS = {}.freeze
end
