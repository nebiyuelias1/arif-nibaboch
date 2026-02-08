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

        book = Book.find_or_create_by!(title: title) do |t|
          t.skip_telegram_callback = true
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

  desc "Publish unpublished books to Telegram with rate limiting"
  task publish_to_telegram: :environment do
    # Telegram rate limits: 30 messages per second to the same group
    # To be safe, we'll use a 1 second delay between posts
    delay_seconds = ENV.fetch("TELEGRAM_DELAY_SECONDS", "1").to_f

    books_without_telegram = Book.where(telegram_post_id: nil)
    total_books = books_without_telegram.count

    puts "Found #{total_books} books without Telegram posts"

    if total_books.zero?
      puts "✅ All books already published to Telegram"
      return
    end

    books_without_telegram.find_each.with_index do |book, index|
      puts "Publishing #{index + 1}/#{total_books}: #{book.title}"

      message_id = TelegramService.new(book).publish
      if message_id
        book.update_column(:telegram_post_id, message_id)
        puts "✅ Successfully published"
      else
        puts "❌ Failed to publish"
      end

      # Sleep to avoid rate limiting (skip for the last item)
      sleep(delay_seconds) unless index == total_books - 1
    end

    puts "\n🎉 Finished publishing books to Telegram"
  end
end
