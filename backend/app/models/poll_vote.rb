class PollVote < ApplicationRecord
  belongs_to :poll_option
  belongs_to :user

  has_one :poll, through: :poll_option

  validates :user_id, uniqueness: { scope: :poll_option_id, message: "has already voted for this option" }
end
