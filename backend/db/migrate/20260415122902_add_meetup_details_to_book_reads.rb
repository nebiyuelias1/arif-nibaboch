class AddMeetupDetailsToBookReads < ActiveRecord::Migration[8.0]
  def change
    add_column :book_reads, :meetup_location, :string
    add_column :book_reads, :meetup_location_lat, :decimal, precision: 10, scale: 6
    add_column :book_reads, :meetup_location_lon, :decimal, precision: 10, scale: 6
    add_column :book_reads, :meetup_time, :datetime
  end
end
