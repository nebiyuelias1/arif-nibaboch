class PollOption < ApplicationRecord
  belongs_to :poll
  belongs_to :book, optional: true
  belongs_to :suggested_by, class_name: "User", optional: true

  has_many :poll_votes, dependent: :destroy

  validates :content, presence: true
end
