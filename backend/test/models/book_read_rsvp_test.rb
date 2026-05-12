require "test_helper"

class BookReadRsvpTest < ActiveSupport::TestCase
  def setup
    @book_read = book_reads(:one)
    @user = users(:one)
  end

  test "is valid with a book read and user" do
    rsvp = BookReadRsvp.new(book_read: @book_read, user: @user, status: :going)
    assert rsvp.valid?
  end

  test "requires a unique user per book read" do
    BookReadRsvp.create!(book_read: @book_read, user: @user, status: :going)
    duplicate = BookReadRsvp.new(book_read: @book_read, user: @user, status: :going)

    assert_not duplicate.valid?
  end

  test "allows going when capacity is available" do
    @book_read.update!(max_capacity: 2)
    BookReadRsvp.create!(book_read: @book_read, user: users(:two), status: :going)

    rsvp = BookReadRsvp.new(book_read: @book_read, user: @user, status: :going)
    assert rsvp.valid?
  end

  test "prevents going when capacity is full" do
    @book_read.update!(max_capacity: 2)
    BookReadRsvp.create!(book_read: @book_read, user: users(:one), status: :going)
    BookReadRsvp.create!(book_read: @book_read, user: users(:two), status: :going)

    rsvp = BookReadRsvp.new(book_read: @book_read, user: @user, status: :going)
    assert_not rsvp.valid?
    assert_includes rsvp.errors.full_messages, "This session is full"
  end

  test "allows waitlisted when capacity is full" do
    @book_read.update!(max_capacity: 2)
    BookReadRsvp.create!(book_read: @book_read, user: users(:one), status: :going)
    BookReadRsvp.create!(book_read: @book_read, user: users(:two), status: :going)

    rsvp = BookReadRsvp.new(book_read: @book_read, user: users(:three), status: :waitlisted)
    assert rsvp.valid?
  end
end
