class BookClub < ApplicationRecord
  belongs_to :owner, class_name: "User", optional: true

  has_one_attached :cover_photo

  has_many :book_reads, dependent: :destroy
  has_many :books, through: :book_reads

  validates :name, presence: true
end
