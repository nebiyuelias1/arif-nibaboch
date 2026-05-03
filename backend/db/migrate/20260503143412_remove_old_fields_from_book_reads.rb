class RemoveOldFieldsFromBookReads < ActiveRecord::Migration[8.0]
  def change
    remove_column :book_reads, :start_date, :date
    remove_column :book_reads, :end_date, :date
    remove_column :book_reads, :status, :integer
    remove_column :book_reads, :meetup_location_lat, :decimal, precision: 10, scale: 6
    remove_column :book_reads, :meetup_location_lon, :decimal, precision: 10, scale: 6
  end
end
