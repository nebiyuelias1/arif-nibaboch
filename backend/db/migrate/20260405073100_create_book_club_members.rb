class CreateBookClubMembers < ActiveRecord::Migration[8.0]
  def change
    create_table :book_club_members do |t|
      t.references :user, null: false, foreign_key: true
      t.references :book_club, null: false, foreign_key: true

      t.timestamps
    end

    add_index :book_club_members, [ :user_id, :book_club_id ], unique: true
  end
end
