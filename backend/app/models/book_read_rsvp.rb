class BookReadRsvp < ApplicationRecord
  enum :status, { going: 0, waitlisted: 1, cancelled: 2 }

  belongs_to :book_read
  belongs_to :user

  validates :status, presence: true
  validates :user_id, uniqueness: { scope: :book_read_id }

  validate :capacity_available_for_going, if: :going?

  after_commit :send_rsvp_email, on: [ :create, :update ], if: -> { going? && (saved_change_to_status? || id_previously_changed?) }

  def self.rsvp!(book_read:, user:, status: :going)
    book_read.with_lock do
      rsvp = book_read.book_read_rsvps.find_or_initialize_by(user: user)
      desired_status = status.to_sym

      if desired_status == :going && book_read.max_capacity.present?
        going_count = book_read.book_read_rsvps.going.where.not(id: rsvp.id).count
        desired_status = :waitlisted if going_count >= book_read.max_capacity
      end

      rsvp.status = desired_status
      rsvp.save!
      rsvp
    end
  end

  private

  def send_rsvp_email
    UserMailer.with(rsvp: self).rsvp_confirmation.deliver_later
  end

  def capacity_available_for_going
    return if book_read.max_capacity.blank?

    going_count = book_read.book_read_rsvps.going.where.not(id: id).count
    return if going_count < book_read.max_capacity

    errors.add(:base, "This session is full")
  end
end
