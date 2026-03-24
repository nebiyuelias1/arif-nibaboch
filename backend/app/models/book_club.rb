class BookClub < ApplicationRecord
  belongs_to :owner, class_name: "User", optional: true

  has_one_attached :cover_photo

  validates :name, presence: true
end
