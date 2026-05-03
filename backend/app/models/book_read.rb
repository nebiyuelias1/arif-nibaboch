class BookRead < ApplicationRecord
  belongs_to :book, optional: true
  belongs_to :book_club

  has_one :poll, dependent: :destroy
  has_many :discussion_questions, dependent: :destroy

  accepts_nested_attributes_for :poll, reject_if: :all_blank

  validates :meetup_time, presence: true
  validates :meetup_location, presence: true

  validate :has_book_or_poll

  private

  def has_book_or_poll
    unless book_id.present? || poll.present?
      errors.add(:base, "You must select a specific book or create a poll for this reading session")
    end
  end
end
