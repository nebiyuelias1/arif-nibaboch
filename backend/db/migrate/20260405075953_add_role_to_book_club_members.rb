class AddRoleToBookClubMembers < ActiveRecord::Migration[8.0]
  def change
    add_column :book_club_members, :role, :integer, default: 0, null: false
  end
end
