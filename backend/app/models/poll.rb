class Poll < ApplicationRecord
  belongs_to :book_read

  has_many :poll_options, dependent: :destroy
  has_many :poll_votes, through: :poll_options

  validates :text, presence: true

  def active?
    end_date.nil? || end_date > Time.current
  end
end
