# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
#

# Only run seeds in non-production environments
if !Rails.env.production?
  puts "🌱 Seeding database for #{Rails.env} environment..."

  # Create or find tags
  tag_names = %w[አማርኛ ፍቅር ታሪክ ባህል የኢትዮጵያ_ልቦና ፖለቲካ ህይወት ልቦና]
  tags = tag_names.index_with { |name| Tag.find_or_create_by!(name: name) }

  # Array of Ethiopian books (currently one)
  books_data = [
    {
      title: "ፍቅር እስከ መቃብር",
      author: "ሐዲስ አለማየሁ",
      description: <<~DESC.strip,
        "ፍቅር እስከ መቃብር" በኢትዮጵያ ሥነ ልቦና ውስጥ ከፍተኛ ዋጋ ያለው መፅሀፍ ነው።#{' '}
        የአንድ ወጣት ወንድና የአንዲት ወጣት ሴት ፍቅርን በኢትዮጵያዊ ህይወትና ባህላዊ ተነሳስተኝነት ይገልጻል።
        የፍቅር ታሪክ በኢትዮጵያ ባህላዊ እና ማኅበራዊ አካባቢ ውስጥ የተደረገ ትንታኔ ነው።
      DESC
      published_at: Date.new(1968, 1, 1),
      language: "am",
      publisher: "Addis Ababa University Press",
      isbn: "9789994400010",
      cover_image: "https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1590965645i/53713557.jpg",
      average_rating: 4.9,
      reviews_count: 0,
      tag_names: %w[አማርኛ ፍቅር ታሪክ ባህል]
    },
    {
      title: "ኦሮማይ",
      author: "በዓሉ ግርማ",
      description: "የ1980ዎቹ በውስጥ የኢትዮጵያ የመንግስት ሥርዓትና የሞት ዘመን ውስጥ የአንድ የቴሌቪዥን ዘጋቢ ታሪክ። የተፈተነው የደርዳር ውጤት በግልፅነት ተገልጿል።",
      published_at: Date.new(1983, 1, 1),
      language: "am",
      publisher: "Kuraz Publishing Agency",
      isbn: "9789994400056",
      cover_image: "https://typicalethiopian.com/wp-content/uploads/2022/03/Oromai_cover.png",
      average_rating: 4.4,
      reviews_count: 430,
      tag_names: %w[አማርኛ ፖለቲካ ታሪክ]
    },
    {
      title: "የተቆለፈበት ቁልፍ",
      author: "ዶ/ር መህረት ደበበ",
      description: "ልዩ ታሪክ በውጭ ተተመው የተነሳ የማኅበረሰብ እና የጭንቀት ጉዳዮችን የሚያሳይ። አብዛኛው በግልፅ አማርኛ ቋንቋ ተጻፈ።",
      published_at: Date.new(1995, 1, 1),
      language: "am",
      publisher: "የኢትዮጵያ ዩኒቨርሲቲ ፕረስ",
      isbn: "9789994400063",
      cover_image: "https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1437980703i/18007965.jpg",
      average_rating: 4.0,
      reviews_count: 290,
      tag_names: %w[አማርኛ ህይወት ልቦና]
    }
  ]

  # Create books and associate tags
  books_data.each do |data|
    tag_list = data.delete(:tag_names)
    book = Book.find_or_create_by!(title: data[:title]) do |b|
      b.assign_attributes(data)
    end
    book.tags = tag_list.map { |name| tags[name] }
    puts "✅ Created book: #{book.title} (Tags: #{tag_list.join(', ')})"
  end
else
  puts "Skipping database seeding in production environment."
end
