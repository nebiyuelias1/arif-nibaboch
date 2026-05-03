class Poll < ApplicationRecord
  belongs_to :book_read

  has_many :poll_options, dependent: :destroy
  has_many :poll_votes, through: :poll_options

  accepts_nested_attributes_for :poll_options, allow_destroy: true, reject_if: :all_blank

  validates :text, presence: true
  validates :end_date, presence: true
  validate :must_have_at_least_two_options

  def active?
    end_date.nil? || end_date > Time.current
  end

  private

  def must_have_at_least_two_options
    if poll_options.reject(&:marked_for_destruction?).length < 2
      errors.add(:base, "Poll must have at least two options")
    end
  end
end
