class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :ratings, dependent: :destroy

  def self.from_telegram_auth(auth_hash)
    # Ensure we can handle both symbol and string keys
    auth = auth_hash.with_indifferent_access

    user = where(telegram_id: auth[:id]).first_or_initialize do |u|
      # TODO: Find ways of getting email address
      u.email = auth[:email].presence || "#{auth[:id]}@telegram.com"
      u.password = Devise.friendly_token[0, 20]
    end
    user.name = [ auth[:first_name], auth[:last_name] ].join(" ").strip
    user.username = auth[:username]
    user.telegram_id = auth[:id]
    user.save!
    user
  end
end
