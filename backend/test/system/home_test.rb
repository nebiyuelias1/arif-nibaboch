require "application_system_test_case"

class HomeTest < ApplicationSystemTestCase
  test "homepage shows upcoming reads when they exist" do
    login_as users(:one)
    BookRead.destroy_all
    book_clubs(:one).book_reads.create!(
      host: users(:one),
      book: books(:one),
      meetup_time: 1.week.from_now,
      meetup_location: "Test Cafe"
    )

    visit root_path

    within "turbo-frame#upcoming_book_reads" do
      assert_selector "#upcoming_book_reads_list > div", count: 1
      assert_no_text "No upcoming reads"
    end
  end

  test "homepage shows an empty state with a create club CTA when there are no upcoming reads" do
    login_as users(:one)
    BookRead.destroy_all

    visit root_path

    within "turbo-frame#upcoming_book_reads" do
      assert_text "No upcoming reads"
      assert_no_selector "#upcoming_book_reads_list > div .card"
      click_link "Create a Book Club"
    end

    assert_selector "h1", text: "Create a New Book Club"
  end

  test "anonymous visitors see a sign-in CTA in the empty state" do
    BookRead.destroy_all

    visit root_path

    within "turbo-frame#upcoming_book_reads" do
      assert_text "No upcoming reads"
      click_link "Create a Book Club"
    end

    assert_current_path new_user_session_path
  end

  test "bottom tab bar is shown on homepage" do
    visit root_path

    assert_selector "nav[aria-label='Bottom']", visible: :all
  end

  test "bottom tab bar is hidden outside homepage" do
    visit terms_path

    assert_no_selector "nav[aria-label='Bottom']", visible: :all
  end
end
