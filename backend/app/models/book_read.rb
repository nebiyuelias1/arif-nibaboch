class BookRead < ApplicationRecord
  belongs_to :book, optional: true
  belongs_to :book_club
  belongs_to :host, class_name: "User"

  has_one :poll, dependent: :destroy
  has_many :discussion_questions, dependent: :destroy
  has_many :book_read_rsvps, dependent: :destroy
  has_many :rsvp_users, through: :book_read_rsvps, source: :user

  accepts_nested_attributes_for :poll, reject_if: :all_blank

  validates :meetup_time, presence: true
  validates :meetup_location, presence: true
  validates :max_capacity, numericality: { only_integer: true, greater_than_or_equal_to: 2 }, allow_nil: true
  validates :host, presence: true

  validate :has_book_or_poll

  ##
  # Determine whether the given user is allowed to post a discussion question for this reading session.
  # Returns `false` for a blank or nil user; otherwise checks membership in the session's RSVP users.
  # @param [User, nil] user - The user to check.
  # @return [Boolean] `true` if the user is an RSVP for this BookRead, `false` otherwise.
  def can_post_discussion_question?(user)
    return false if user.blank?

    rsvp_users.exists?(id: user.id)
  end

  private

  ##
  # Ensures the record has either an associated book or a poll.
  # Adds an error on :base with message "You must select a specific book or create a poll for this reading session"
  # when neither `book_id` nor `poll` is present.
  def has_book_or_poll
    unless book_id.present? || poll.present?
      errors.add(:base, "You must select a specific book or create a poll for this reading session")
    end
  end
end
