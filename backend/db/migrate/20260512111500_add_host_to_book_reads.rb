class AddHostToBookReads < ActiveRecord::Migration[7.1]
  def change
    add_reference :book_reads, :host, null: true, foreign_key: { to_table: :users }

    reversible do |dir|
      dir.up do
        default_host_id = User.order(:id).limit(1).pick(:id)
        if default_host_id
          BookRead.where(host_id: nil).update_all(host_id: default_host_id)
        end
      end
    end

    change_column_null :book_reads, :host_id, false
  end
end
