class BookClub < ApplicationRecord
  belongs_to :owner, class_name: "User", optional: true

  has_one_attached :cover_photo

  has_many :book_reads, dependent: :destroy
  has_many :books, through: :book_reads
  has_many :book_club_members, dependent: :destroy
  has_many :members, through: :book_club_members, source: :user

  validates :name, presence: true

  after_create :add_owner_as_admin

  private

  def add_owner_as_admin
    if owner.present?
      book_club_members.create!(user: owner, role: :admin)
    end
  end
end
