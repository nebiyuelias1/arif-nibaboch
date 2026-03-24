class AllowNullOwnerOnBookClubs < ActiveRecord::Migration[8.0]
  def change
    change_column_null :book_clubs, :owner_id, true
  end
end
