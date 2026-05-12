class AddHostToBookReads < ActiveRecord::Migration[7.1]
  def change
    add_reference :book_reads, :host, null: true, foreign_key: { to_table: :users }

    reversible do |dir|
      dir.up do
        BookRead.where(host_id: nil).find_each do |book_read|
          book_read.update_columns(host_id: book_read.book_club.owner_id)
        end
      end
    end

    change_column_null :book_reads, :host_id, false
  end
end
