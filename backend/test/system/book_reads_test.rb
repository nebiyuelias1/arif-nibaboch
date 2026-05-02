require "application_system_test_case"

class BookReadsTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    @book_club = book_clubs(:one)
    Book.rebuild_search_index
    login_as @user
  end

  test "creating a book read with a specific book" do
    book = books(:one)
    visit new_book_club_book_read_path(@book_club)

    # Search for and select a book
    fill_in "book_search_input", with: book.title
    # Wait for autocomplete and click the first matching result
    assert_selector "[data-book-autocomplete-target='results'] div", text: book.title, wait: 5
    find("[data-book-autocomplete-target='results'] div", text: book.title, match: :first).click

    fill_in "Meetup time", with: (Time.current + 1.week).strftime("%m%d%Y\t%I%M%p")
    fill_in "Meetup location", with: "Starbucks"

    click_on "Schedule Read"

    assert_text "Book read scheduled successfully"
    assert_text book.title
  end

  test "showing errors when creating a book read without a book or poll" do
    visit new_book_club_book_read_path(@book_club)

    fill_in "Meetup time", with: (Time.current + 1.week).strftime("%m%d%Y\t%I%M%p")
    fill_in "Meetup location", with: "Starbucks"

    click_on "Schedule Read"

    assert_text "You must select a specific book or create a poll for this reading session"
  end

  test "creating a book read via a poll" do
    visit new_book_club_book_read_path(@book_club)

    # Toggle to Poll
    find("[data-book-read-form-target='selectionBtn']", text: "Poll").click

    fill_in "Poll Question", with: "What should we read next?"
    fill_in "Voting Ends On", with: (Date.current + 3.days).strftime("%m%d%Y")

    fill_in "Meetup time", with: (Time.current + 1.week).strftime("%m%d%Y\t%I%M%p")
    fill_in "Meetup location", with: "Public Library"

    click_on "Schedule Read"

    assert_text "Book read scheduled successfully"
    assert_text "What should we read next?"
    assert_text "Public Library"
    assert_text "Voting in Progress"
  end

  private

  def login_as(user)
    visit new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "password123"
    click_on "Log in"
  end
end
