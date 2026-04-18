require "administrate/base_dashboard"

class BookReadDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    book: Field::BelongsTo,
    book_club: Field::BelongsTo,
    discussion_questions: Field::HasMany,
    end_date: Field::Date,
    meetup_location: Field::String,
    meetup_location_lat: Field::String.with_options(searchable: false),
    meetup_location_lon: Field::String.with_options(searchable: false),
    meetup_time: Field::DateTime,
    start_date: Field::Date,
    status: Field::Select.with_options(searchable: false, collection: ->(field) { field.resource.class.send(field.attribute.to_s.pluralize).keys }),
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    id
    book
    book_club
    discussion_questions
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    book
    book_club
    discussion_questions
    end_date
    meetup_location
    meetup_location_lat
    meetup_location_lon
    meetup_time
    start_date
    status
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    book
    book_club
    discussion_questions
    end_date
    meetup_location
    meetup_location_lat
    meetup_location_lon
    meetup_time
    start_date
    status
  ].freeze

  # COLLECTION_FILTERS
  # a hash that defines filters that can be used while searching via the search
  # field of the dashboard.
  #
  # For example to add an option to search for open resources by typing "open:"
  # in the search field:
  #
  #   COLLECTION_FILTERS = {
  #     open: ->(resources) { resources.where(open: true) }
  #   }.freeze
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how book reads are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(book_read)
  #   "BookRead ##{book_read.id}"
  # end
end
