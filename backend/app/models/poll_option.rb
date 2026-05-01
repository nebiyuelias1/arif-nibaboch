class PollOption < ApplicationRecord
  belongs_to :poll
  belongs_to :book

  has_many :poll_votes, dependent: :destroy
end
