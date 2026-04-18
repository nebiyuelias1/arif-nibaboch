require "administrate/base_dashboard"

class BookClubDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    book_club_members: Field::HasMany,
    book_club_members_count: Field::Number,
    book_reads: Field::HasMany,
    books: Field::HasMany,
    cover_photo_attachment: Field::HasOne,
    cover_photo_blob: Field::HasOne,
    description: Field::Text,
    is_private: Field::Boolean,
    members: Field::HasMany,
    name: Field::String,
    owner: Field::BelongsTo,
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
    book_club_members
    book_club_members_count
    book_reads
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    book_club_members
    book_club_members_count
    book_reads
    books
    cover_photo_attachment
    cover_photo_blob
    description
    is_private
    members
    name
    owner
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    book_club_members
    book_club_members_count
    book_reads
    books
    cover_photo_attachment
    cover_photo_blob
    description
    is_private
    members
    name
    owner
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

  # Overwrite this method to customize how book clubs are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(book_club)
  #   "BookClub ##{book_club.id}"
  # end
end
