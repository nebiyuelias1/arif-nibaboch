require "csv"
require "open-uri"

namespace :import_books do
  desc "Import books from csv into db"
  task sync_books: :environment do
    url = "https://raw.githubusercontent.com/nebiyuelias1/book-scraper/refs/heads/main/data/ethiopian_books.csv"
    begin
      csv_text = URI.open(url).read
      csv = CSV.parse(csv_text, headers: true, encoding: "UTF-8")

      total_books_imported = 0
      csv.each do |row|
        next if row["author"].blank?
        puts "#{row["title"]}"

        title = row["title"]
        total_books_imported += 1

        Book.find_or_create_by!(title: title) do |t|
          t.author = row["author"]
          t.description = row["description"]

          if row["published_at"].present?
            t.published_at = begin
                               row["published_at"].to_date
                             rescue Date::Error
                               # Fallback for year-only strings
                               Date.new(row["published_at"].to_i, 1, 1) if row["published_at"].match?(/^\d{4}$/)
                             end
          end

          t.language = row["language"]
          t.cover_image = row["cover_image"]
          t.publisher = row["publisher"]
          t.isbn = row["publisher"]
          t.source = row["source"]
          t.source_url = row["url"]
          t.title_en = row["title_en"]
          t.title_romanized = row["title_romanized"]
          t.author_romanized = row["author_romanized"]
          t.page_count = row["page_count"]
        end

        print "."
      end
      puts "Imported a total of: #{total_books_imported} books."
    end
  end
end
