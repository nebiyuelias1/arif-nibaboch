class BookRead < ApplicationRecord
  belongs_to :book
  belongs_to :book_club

  has_many :discussion_questions, dependent: :destroy

  validates :start_date, presence: true

  enum :status, { upcoming: 0, active: 1, completed: 2 }, default: :upcoming

  validate :end_date_after_start_date

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    if end_date < start_date
      errors.add(:end_date, "must be after the start date")
    end
  end
end
