class AddSuggestedByToPollOptions < ActiveRecord::Migration[8.0]
  def change
    add_reference :poll_options, :suggested_by, null: true, foreign_key: { to_table: :users }
  end
end
