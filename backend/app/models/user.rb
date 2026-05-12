class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :ratings, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :review_likes, dependent: :destroy
  has_many :owned_book_clubs, class_name: "BookClub", foreign_key: "owner_id", dependent: :nullify
  has_many :book_read_rsvps, dependent: :destroy
  has_many :rsvp_book_reads, through: :book_read_rsvps, source: :book_read

  def self.from_telegram_auth(auth)
    user = where(telegram_id: auth["id"]).first_or_initialize do |u|
      u.password = Devise.friendly_token[0, 20]
      # TODO: Find ways of getting email address
      u.email = "#{auth["id"]}@telegram.com"
    end
    user.name = [ auth["first_name"], auth["last_name"] ].join(" ").strip
    user.username = auth["username"]
    user.avatar_url = auth["photo_url"] if auth["photo_url"].present?
    user.telegram_id = auth["id"]
    user.save!
    user
  end

  def self.from_line_auth(auth)
    user = where(line_id: auth["userId"]).first_or_initialize do |u|
      u.password = Devise.friendly_token[0, 20]
      u.email = "#{auth["userId"]}@line.com"
    end
    user.name = auth["displayName"]
    user.username = auth["displayName"]
    user.avatar_url = auth["pictureUrl"] if auth["pictureUrl"].present?
    user.line_id = auth["userId"]
    user.save!
    user
  end

  def to_s
    name.presence || username.presence || email || "Unknown"
  end

  def name_initial
    to_s.strip.first.upcase || "U"
  end
end
