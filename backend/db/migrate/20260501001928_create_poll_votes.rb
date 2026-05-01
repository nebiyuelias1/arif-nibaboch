class CreatePollVotes < ActiveRecord::Migration[8.0]
  def change
    create_table :poll_votes do |t|
      t.references :poll_option, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :poll_votes, [:poll_option_id, :user_id], unique: true
  end
end
