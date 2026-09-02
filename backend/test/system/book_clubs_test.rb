require "application_system_test_case"

class BookClubsTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    @club = book_clubs(:one)
    login_as @user
  end

  test "toggling private shows and enables the application form url field" do
    visit edit_book_club_path(@club)

    assert_no_selector "div[data-conditional-fields-target='field']", visible: true
    assert_selector "input[name='book_club[application_form_url]'][disabled]", visible: :all

    find("input[name='book_club[is_private]']").check

    assert_selector "div[data-conditional-fields-target='field']", visible: true
    assert_no_selector "input[name='book_club[application_form_url]'][disabled]", visible: :all

    fill_in "Application Form URL", with: "https://docs.google.com/forms/d/abc123"
    click_on "Update Club"

    assert_text "Book Club updated successfully"
    @club.reload
    assert @club.is_private
    assert_equal "https://docs.google.com/forms/d/abc123", @club.application_form_url
  end

  test "private club card in discover carousel renders apply dialog outside anchors" do
    private_club = BookClub.create!(
      name: "Secret Readers",
      description: "A private club",
      is_private: true,
      owner: users(:two)
    )

    visit root_path

    card = find("#book_club_#{private_club.id}")

    # The dialog must live inside the card wrapper and never inside an anchor.
    # A nested <a> (dialog link inside the carousel link) is invalid HTML and
    # makes the browser parser mangle the whole card DOM.
    assert_selector "#book_club_#{private_club.id} #apply_dialog_#{private_club.id}", visible: :all
    assert_no_selector "a #apply_dialog_#{private_club.id}", visible: :all

    within card do
      click_button "Apply to Join"
    end

    assert_selector "#apply_dialog_#{private_club.id}[open]"
    assert_text "This is a private book club"
  end

  test "member can leave a joined private club and request to join again" do
    @club.update!(is_private: true, application_form_url: "https://test-form.com")
    request = @club.membership_requests.create!(user: users(:two), status: :pending)
    request.approve!
    assert @club.has_member?(users(:two))

    login_as users(:two)
    visit book_club_path(@club)

    # Leave via the show page button
    assert_selector "button#book_club_show_join_button", text: /Leave Club/
    click_on "Leave Club"

    # Button swaps straight to Apply to Join, never Join Club
    assert_selector "button#book_club_show_join_button", text: /Apply to Join/
    assert_no_selector "button", text: /Join Club/
    assert_not @club.has_member?(users(:two))

    # Re-apply through the restored dialog
    click_button "Apply to Join"
    assert_selector "#apply_dialog_#{@club.id}[open]"

    check "I understand my request will be reviewed by the club admin"
    click_button "Send Request"

    # The request goes through: button swaps to Cancel Join Request and the
    # stale approved record is reset to pending for the owner to review
    assert_selector "#book_club_show_join_button", text: /Cancel Join Request/
    assert request.reload.pending?
    assert @club.pending_membership_requests.exists?(user: users(:two))
  end

  test "member can leave a private club from the discover carousel and apply again" do
    @club.update!(is_private: true, application_form_url: "https://test-form.com")
    request = @club.membership_requests.create!(user: users(:two), status: :pending)
    request.approve!

    login_as users(:two)
    visit root_path

    # Leave from the card in the discover carousel
    within "#book_club_#{@club.id}" do
      assert_selector "button", text: "Joined"
      click_on "Joined"
    end

    # Card swaps straight to the apply state, never a direct Join
    within "#book_club_#{@club.id}" do
      assert_selector "button", text: /Apply to Join/
      assert_no_selector "button", text: /Join Club/
    end
    assert_not @club.has_member?(users(:two))

    # Exactly one apply dialog on the page - the one inside the replaced
    # card. No duplicate appended to the toast triggers.
    assert_selector "#apply_dialog_#{@club.id}", visible: :all, count: 1

    # Re-apply through the card dialog
    within "#book_club_#{@club.id}" do
      click_button "Apply to Join"
    end
    assert_selector "#apply_dialog_#{@club.id}[open]"

    check "I understand my request will be reviewed by the club admin"
    click_button "Send Request"

    # The request goes through: card swaps to Cancel Join Request and the
    # stale approved record is reset to pending for the owner to review
    assert_selector "#book_club_#{@club.id} button", text: /Cancel Join Request/
    assert request.reload.pending?
    assert @club.pending_membership_requests.exists?(user: users(:two))
  end
end
