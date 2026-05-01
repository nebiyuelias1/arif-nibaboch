class ChangeBookIdNullInBookReads < ActiveRecord::Migration[8.0]
  def change
    change_column_null :book_reads, :book_id, true
  end
end
