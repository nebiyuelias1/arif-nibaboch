class BookRead < ApplicationRecord
  belongs_to :book, optional: true
  belongs_to :book_club

  has_one :poll, dependent: :destroy
  has_many :discussion_questions, dependent: :destroy
  has_many :book_read_rsvps, dependent: :destroy
  has_many :rsvp_users, through: :book_read_rsvps, source: :user

  accepts_nested_attributes_for :poll, reject_if: :all_blank

  validates :meetup_time, presence: true
  validates :meetup_location, presence: true
  validates :max_capacity, numericality: { only_integer: true, greater_than_or_equal_to: 2 }, allow_nil: true

  validate :has_book_or_poll

  private

  def has_book_or_poll
    unless book_id.present? || poll.present?
      errors.add(:base, "You must select a specific book or create a poll for this reading session")
    end
  end
end
