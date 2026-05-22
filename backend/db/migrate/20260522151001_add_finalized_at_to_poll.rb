class AddFinalizedAtToPoll < ActiveRecord::Migration[8.0]
  def change
    add_column :polls, :finalized_at, :datetime, null: true
  end
end
