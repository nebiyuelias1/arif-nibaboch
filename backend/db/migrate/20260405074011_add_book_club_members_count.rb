class AddBookClubMembersCount < ActiveRecord::Migration[8.0]
  def change
    add_column :book_clubs, :book_club_members_count, :integer, default: 0, null: false
  end
end
