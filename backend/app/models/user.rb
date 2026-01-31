class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :ratings, dependent: :destroy

  def self.from_telegram_auth(auth_hash)
    auth = auth_hash

    user = where(telegram_id: auth["id"]).first_or_initialize do |u|
      u.password = Devise.friendly_token[0, 20]
      # TODO: Find ways of getting email address
      user.email = "#{auth["id"]}@telegram.com"
    end
    user.name = [ auth["first_name"], auth["last_name"] ].join(" ").strip
    user.username = auth["username"]
    user.telegram_id = auth["id"]
    user.save!
    user
  end
end
