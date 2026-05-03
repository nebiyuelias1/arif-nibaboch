require "application_system_test_case"

class BookReadsTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    @book_club = book_clubs(:one)
    Book.rebuild_search_index
    login_as @user
  end

  test "toggling between book and poll selection in book read form" do
    visit new_book_club_book_read_path(@book_club)

    assert_selector "h1", text: "Schedule a Book Read"

    # Default state (Book Selection)
    assert_selector "#book_selection_field", visible: true
    assert_no_selector "#poll_fields", visible: true

    # Toggle to Poll
    find("[data-book-read-form-target='selectionBtn']", text: "Poll").click
    assert_no_selector "#book_selection_field", visible: true
    assert_selector "#poll_fields", visible: true
    # Check for simplified event fields
    assert_selector "label", text: "Meetup time"
    assert_selector "label", text: "Meetup location"

    # Toggle back to Book
    find("[data-book-read-form-target='selectionBtn']", text: "Specific Book").click

    assert_selector "#book_selection_field", visible: true
    assert_no_selector "#poll_fields", visible: true
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

  test "creating a book read via a poll with options" do
    visit new_book_club_book_read_path(@book_club)

    # Toggle to Poll
    find("[data-book-read-form-target='selectionBtn']", text: "Poll").click

    fill_in "Poll Question", with: "What should we read next?"
    fill_in "Voting Ends On", with: (Time.current + 3.days).strftime("%m%d%Y\t%I%M%p")

    # Add Poll Options
    within "#poll_options" do
      # Enter first option
      within ".poll-option-field:nth-child(1)" do
        fill_in "Enter book title or option...", with: "The Great Gatsby"
      end

      # Enter second option
      within ".poll-option-field:nth-child(2)" do
        fill_in "Enter book title or option...", with: "1984"
      end

      click_button "Add Another Option"

      # Enter third option
      within ".poll-option-field:nth-child(3)" do
        fill_in "Enter book title or option...", with: "Brave New World"
      end
    end

    fill_in "Meetup time", with: (Time.current + 1.week).strftime("%m%d%Y\t%I%M%p")
    fill_in "Meetup location", with: "Public Library"

    click_on "Schedule Read"

    assert_text "Book read scheduled successfully"
    assert_text "What should we read next?"
    assert_text "The Great Gatsby"
    assert_text "1984"
    assert_text "Brave New World"
    assert_text "Public Library"
    assert_text "Voting ends on"
  end

  test "selection type persists after validation error" do
    visit new_book_club_book_read_path(@book_club)

    # Toggle to Poll
    find("[data-book-read-form-target='selectionBtn']", text: "Poll").click
    assert_selector "#poll_fields", visible: true

    # Fill some fields but miss a required one (meetup_time)
    fill_in "Poll Question", with: "Incomplete Poll"
    fill_in "Meetup location", with: "Nowhere"

    click_on "Schedule Read"

    # Should show error
    assert_text "prohibited this book read from being saved"

    # Selection should still be Poll
    assert_selector "#poll_fields", visible: true
    assert_no_selector "#book_selection_field", visible: true

    # The Poll radio should be checked
    assert find("input[name='selection_type'][value='poll']", visible: false).checked?
  end

  test "showing errors when creating a poll without options" do
    visit new_book_club_book_read_path(@book_club)

    # Toggle to Poll
    find("[data-book-read-form-target='selectionBtn']", text: "Poll").click

    fill_in "Poll Question", with: "Poll with no options"
    fill_in "Voting Ends On", with: (Time.current + 3.days).strftime("%m%d%Y\t%I%M%p")

    fill_in "Meetup time", with: (Time.current + 1.week).strftime("%m%d%Y\t%I%M%p")
    fill_in "Meetup location", with: "Public Library"

    # Ensure options are empty (they shouldn't be by default as we build 2, but let's assume we remove them or they are blank)
    # Our form builds 2 empty ones by default, so if we leave them blank they should be rejected by reject_if: :all_blank

    click_on "Schedule Read"

    assert_text "Poll must have at least two options"
  end

  private

  def login_as(user)
    visit new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "password123"
    click_on "Log in"
  end
end
