class PollOption < ApplicationRecord
  belongs_to :poll
  belongs_to :book, optional: true

  has_many :poll_votes, dependent: :destroy

  validates :content, presence: true
end
