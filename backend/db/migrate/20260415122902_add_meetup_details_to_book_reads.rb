class AddMeetupDetailsToBookReads < ActiveRecord::Migration[8.0]
  def change
    add_column :book_reads, :meetup_location, :string
    add_column :book_reads, :meetup_location_lat, :float
    add_column :book_reads, :meetup_location_lon, :float
    add_column :book_reads, :meetup_time, :datetime
  end
end
