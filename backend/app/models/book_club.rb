class BookClub < ApplicationRecord
  belongs_to :owner

  has_one_attached :cover_photo

  validates :name, presence: true
end
