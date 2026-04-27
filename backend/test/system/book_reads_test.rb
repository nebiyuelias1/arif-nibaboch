require "application_system_test_case"

class BookReadsTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @book_club = book_clubs(:one)
  end

  test "creating a book read with a poll fails validation and retains form state" do
    sign_in @user
    visit new_book_club_book_read_path(@book_club)

    choose "Create a Poll"

    assert_selector "h3", text: "Book Poll"

    fill_in "Start date", with: Date.today

    click_on "Start Book Read"

    assert_text "Poll title can't be blank"
    assert_text "Poll must have at least one option"

    assert_checked_field "Create a Poll"

    assert_selector "input[placeholder='Option text (e.g. Book title)']", count: 3
  end
end
