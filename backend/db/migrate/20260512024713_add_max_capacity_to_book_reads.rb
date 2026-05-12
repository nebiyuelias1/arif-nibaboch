class AddMaxCapacityToBookReads < ActiveRecord::Migration[8.0]
  def change
    add_column :book_reads, :max_capacity, :integer, null: true

    add_check_constraint :book_reads, "max_capacity IS NULL OR max_capacity >= 2", name: "book_reads_max_capacity_min"
  end
end
