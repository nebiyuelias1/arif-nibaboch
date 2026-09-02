# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.

if !Rails.env.production?
  puts "🌱 Seeding database for #{Rails.env} environment..."

  # Clear existing records in development to ensure clean & reproducible seeding
  puts "🧹 Cleaning database..."
  BookReadRsvp.destroy_all
  PollVote.destroy_all
  PollOption.destroy_all
  Poll.destroy_all
  DiscussionQuestion.destroy_all
  BookRead.destroy_all
  BookClubMember.destroy_all
  BookClub.destroy_all
  BookTag.destroy_all
  Tag.destroy_all
  ReviewLike.destroy_all
  Review.destroy_all
  Rating.destroy_all
  Book.destroy_all

  # 1. Tags
  puts "🏷️ Creating Tags..."
  tag_names = %w[አማርኛ ፍቅር ታሪክ ባህል ህይወት ልቦና ፖለቲካ Fiction Non-Fiction Philosophy African\ Literature Sci-Fi]
  tags = tag_names.index_with { |name| Tag.find_or_create_by!(name: name) }

  # 2. Users
  puts "👥 Creating Users..."
  users_data = [
    { name: "Abebe Bikila", email: "abebe@example.com" },
    { name: "Kebede Michael", email: "kebede@example.com" },
    { name: "Tigist Haile", email: "tigist@example.com" },
    { name: "Martha Wolde", email: "martha@example.com" },
    { name: "Yonas Alemu", email: "yonas@example.com" },
    { name: "Helen Tadesse", email: "helen@example.com" },
    { name: "Samuel Gebre", email: "samuel@example.com" },
    { name: "Selamawit Assefa", email: "selam@example.com" }
  ]

  users = users_data.map do |udata|
    user = User.find_or_initialize_by(email: udata[:email])
    user.name = udata[:name]
    user.password = "password123"
    user.password_confirmation = "password123"
    user.confirmed_at = Time.current
    user.save!
    user
  end

  admin_user = users.first
  admin_user.update!(admin: true)

  # 3. Books (12 books)
  puts "📚 Creating Books..."
  books_data = [
    {
      title: "ፍቅር እስከ መቃብር",
      author: "ሐዲስ አለማየሁ",
      description: "በኢትዮጵያ ሥነ ልቦና ውስጥ ከፍተኛ ዋጋ ያለው መፅሀፍ ነው። የአንድ ወጣት ወንድና የአንዲት ወጣት ሴት ፍቅርን በኢትዮጵያዊ ህይወትና ባህላዊ ተነሳስተኝነት ይገልጻል።",
      published_at: Date.new(1968, 1, 1),
      language: "am",
      publisher: "Addis Ababa University Press",
      isbn: "9789994400010",
      cover_image: "https://images.unsplash.com/photo-1544947950-fa07a98d237f?auto=format&fit=crop&w=600&q=80",
      average_rating: 4.9,
      reviews_count: 120,
      tag_names: %w[አማርኛ ፍቅር ታሪክ ባህል]
    },
    {
      title: "ኦሮማይ",
      author: "በዓሉ ግርማ",
      description: "የ1980ዎቹ በውስጥ የኢትዮጵያ የመንግስት ሥርዓትና የሞት ዘመን ውስጥ የአንድ የቴሌቪዥን ዘጋቢ ታሪክ።",
      published_at: Date.new(1983, 1, 1),
      language: "am",
      publisher: "Kuraz Publishing Agency",
      isbn: "9789994400056",
      cover_image: "https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&w=600&q=80",
      average_rating: 4.8,
      reviews_count: 95,
      tag_names: %w[አማርኛ ፖለቲካ ታሪክ]
    },
    {
      title: "የተቆለፈበት ቁልፍ",
      author: "ዶ/ር መህረት ደበበ",
      description: "ልዩ ታሪክ በውጭ ተተመው የተነሳ የማኅበረሰብ እና የጭንቀት ጉዳዮችን የሚያሳይ።",
      published_at: Date.new(1995, 1, 1),
      language: "am",
      publisher: "የኢትዮጵያ ዩኒቨርሲቲ ፕረስ",
      isbn: "9789994400063",
      cover_image: "https://images.unsplash.com/photo-1543002588-bfa74002ed7e?auto=format&fit=crop&w=600&q=80",
      average_rating: 4.5,
      reviews_count: 88,
      tag_names: %w[አማርኛ ህይወት ልቦና]
    },
    {
      title: "አልወለድም",
      author: "በዓሉ ግርማ",
      description: "ስለ ፍልስፍና፣ ነፃነት እና ማህበራዊ ፍትህ የሚያትት ድንቅ የኢትዮጵያ ልቦለድ መፅሐፍ።",
      published_at: Date.new(1974, 1, 1),
      language: "am",
      publisher: "Kuraz Publishing",
      isbn: "9789994400070",
      cover_image: "https://images.unsplash.com/photo-1497633762265-9d179a990aa6?auto=format&fit=crop&w=600&q=80",
      average_rating: 4.7,
      reviews_count: 64,
      tag_names: %w[አማርኛ ፖለቲካ]
    },
    {
      title: "Things Fall Apart",
      author: "Chinua Achebe",
      description: "A classic novel exploring pre-colonial life in Nigeria and the arrival of European colonizers in the late nineteenth century.",
      published_at: Date.new(1958, 6, 17),
      language: "en",
      publisher: "Heinemann",
      isbn: "9780385474542",
      cover_image: "https://images.unsplash.com/photo-1532012197267-da84d127e765?auto=format&fit=crop&w=600&q=80",
      average_rating: 4.6,
      reviews_count: 210,
      tag_names: [ "Fiction", "African Literature" ]
    },
    {
      title: "The Alchemist",
      author: "Paulo Coelho",
      description: "An inspiring fable about following your dreams, listening to your heart, and reading the omens scattered along life's path.",
      published_at: Date.new(1988, 1, 1),
      language: "en",
      publisher: "HarperOne",
      isbn: "9780062315007",
      cover_image: "https://images.unsplash.com/photo-1516979187457-637abb4f9353?auto=format&fit=crop&w=600&q=80",
      average_rating: 4.7,
      reviews_count: 350,
      tag_names: %w[Fiction Philosophy]
    },
    {
      title: "Atomic Habits",
      author: "James Clear",
      description: "An easy & proven way to build good habits & break bad ones, offering a proven framework for self-improvement every day.",
      published_at: Date.new(2018, 10, 16),
      language: "en",
      publisher: "Avery",
      isbn: "9780735211292",
      cover_image: "https://images.unsplash.com/photo-1589829085413-56de8ae18c73?auto=format&fit=crop&w=600&q=80",
      average_rating: 4.9,
      reviews_count: 500,
      tag_names: %w[Non-Fiction]
    },
    {
      title: "Sapiens: A Brief History of Humankind",
      author: "Yuval Noah Harari",
      description: "A groundbreaking narrative of humanity's creation and evolution that explores how biology and history have defined us.",
      published_at: Date.new(2014, 9, 4),
      language: "en",
      publisher: "Harper",
      isbn: "9780062316097",
      cover_image: "https://images.unsplash.com/photo-1457369804613-52c61a468e7d?auto=format&fit=crop&w=600&q=80",
      average_rating: 4.8,
      reviews_count: 420,
      tag_names: %w[Non-Fiction Philosophy]
    },
    {
      title: "1984",
      author: "George Orwell",
      description: "A dystopian social science fiction novel and cautionary tale about totalitarianism, mass surveillance, and repressive regimentation.",
      published_at: Date.new(1949, 6, 8),
      language: "en",
      publisher: "Secker & Warburg",
      isbn: "9780451524935",
      cover_image: "https://images.unsplash.com/photo-1541963463532-d68292c34b19?auto=format&fit=crop&w=600&q=80",
      average_rating: 4.7,
      reviews_count: 610,
      tag_names: %w[Fiction Sci-Fi]
    },
    {
      title: "የቀን መሐሪ",
      author: "ሐዲስ አለማየሁ",
      description: "የማህበራዊና ባህላዊ ሁነቶችን የሚዳስስ ድንቅ የኢትዮጵያ ስነ ጽሁፍ ውጤት።",
      published_at: Date.new(1970, 1, 1),
      language: "am",
      publisher: "Kuraz Agency",
      isbn: "9789994400087",
      cover_image: "https://images.unsplash.com/photo-1476275466078-4007374efbbe?auto=format&fit=crop&w=600&q=80",
      average_rating: 4.3,
      reviews_count: 35,
      tag_names: %w[አማርኛ ታሪክ]
    },
    {
      title: "Dune",
      author: "Frank Herbert",
      description: "Set on the desert planet Arrakis, Dune is the story of the boy Paul Atreides, heir to a noble family in a interstellar empire.",
      published_at: Date.new(1965, 8, 1),
      language: "en",
      publisher: "Chilton Books",
      isbn: "9780441172719",
      cover_image: "https://images.unsplash.com/photo-1506880018603-83d5b814b5a6?auto=format&fit=crop&w=600&q=80",
      average_rating: 4.8,
      reviews_count: 310,
      tag_names: %w[Fiction Sci-Fi]
    },
    {
      title: "The Death of Vivek Oji",
      author: "Akwaeke Emezi",
      description: "A deeply affecting, atmospheric novel about family, identity, and innocence set in southeastern Nigeria.",
      published_at: Date.new(2020, 8, 4),
      language: "en",
      publisher: "Riverhead Books",
      isbn: "9780525541608",
      cover_image: "https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?auto=format&fit=crop&w=600&q=80",
      average_rating: 4.6,
      reviews_count: 140,
      tag_names: [ "Fiction", "African Literature" ]
    }
  ]

  created_books = books_data.map do |bdata|
    t_names = bdata.delete(:tag_names)
    book = Book.create!(bdata)
    book.tags = t_names.map { |tn| tags[tn] }
    book
  end

  # 4. Book Clubs (5 clubs)
  puts "🏛️ Creating Book Clubs..."
  clubs_data = [
    {
      name: "አዲስ አበባ መፅሐፍ ክለብ",
      description: "በአዲስ አበባ እና በዙሪያዋ ያሉ የመፅሐፍ ወዳጆች የሚገናኙበትና በኢትዮጵያ ስነ ጽሁፍ ላይ የሚወያዩበት ክለብ።",
      owner: users[0]
    },
    {
      name: "Habesha Readers Circle",
      description: "A community for literature enthusiasts across East Africa discussing contemporary African writing & historical classics.",
      owner: users[1]
    },
    {
      name: "African Classics Society",
      description: "Dedicated to exploring foundational novels and philosophical works by celebrated African authors.",
      owner: users[2]
    },
    {
      name: "Non-Fiction & Productivity Hub",
      description: "Weekly deep dives into habit building, personal finance, history, and science.",
      owner: users[3]
    },
    {
      name: "Addis Sci-Fi & Speculative Readers",
      description: "Exploring dystopian worlds, futuristic fiction, and speculative novels from around the globe.",
      owner: users[4]
    }
  ]

  created_clubs = clubs_data.map do |cdata|
    BookClub.create!(cdata)
  end

  # Add members to clubs
  created_clubs.each do |club|
    users.sample(4).each do |u|
      unless club.has_member?(u)
        club.book_club_members.create!(user: u, role: :member)
      end
    end
  end

  # 5. Book Reads (12 book reads)
  puts "📖 Creating Book Reads (12 sessions)..."
  meetup_locations = [
    "National Archive & Library Agency (NALA), Addis Ababa",
    "Tomoca Coffee (Kazanchis Branch), Addis Ababa",
    "Fendika Cultural Center, Kazanchis",
    "Online via Google Meet",
    "Galani Coffee, Sarbet",
    "Urban Center, Meskel Square",
    "Kaldi's Coffee, Bole Medhanealem",
    "Bole Public Library"
  ]

  reads_data = [
    {
      book_club: created_clubs[0],
      book: created_books[0], # ፍቅር እስከ መቃብር
      host: users[0],
      meetup_time: 2.days.from_now + 4.hours,
      meetup_location: meetup_locations[0],
      max_capacity: 25
    },
    {
      book_club: created_clubs[0],
      book: created_books[1], # ኦሮማይ
      host: users[1],
      meetup_time: 5.days.from_now + 2.hours,
      meetup_location: meetup_locations[1],
      max_capacity: 20
    },
    {
      book_club: created_clubs[1],
      book: created_books[4], # Things Fall Apart
      host: users[1],
      meetup_time: 7.days.from_now + 3.hours,
      meetup_location: meetup_locations[2],
      max_capacity: 15
    },
    {
      book_club: created_clubs[1],
      book: created_books[5], # The Alchemist
      host: users[2],
      meetup_time: 10.days.from_now + 1.hour,
      meetup_location: meetup_locations[3],
      max_capacity: 30
    },
    {
      book_club: created_clubs[2],
      book: created_books[11], # The Death of Vivek Oji
      host: users[2],
      meetup_time: 12.days.from_now + 5.hours,
      meetup_location: meetup_locations[4],
      max_capacity: 18
    },
    {
      book_club: created_clubs[3],
      book: created_books[6], # Atomic Habits
      host: users[3],
      meetup_time: 14.days.from_now + 2.hours,
      meetup_location: meetup_locations[3],
      max_capacity: 40
    },
    {
      book_club: created_clubs[3],
      book: created_books[7], # Sapiens
      host: users[4],
      meetup_time: 18.days.from_now + 6.hours,
      meetup_location: meetup_locations[5],
      max_capacity: 25
    },
    {
      book_club: created_clubs[4],
      book: created_books[8], # 1984
      host: users[4],
      meetup_time: 21.days.from_now + 3.hours,
      meetup_location: meetup_locations[6],
      max_capacity: 20
    },
    {
      book_club: created_clubs[4],
      book: created_books[10], # Dune
      host: users[5],
      meetup_time: 25.days.from_now + 4.hours,
      meetup_location: meetup_locations[3],
      max_capacity: 35
    },
    {
      book_club: created_clubs[0],
      book: created_books[2], # የተቆለፈበት ቁልፍ
      host: users[0],
      meetup_time: 28.days.from_now + 2.hours,
      meetup_location: meetup_locations[7],
      max_capacity: 20
    },
    {
      book_club: created_clubs[2],
      book: created_books[3], # አልወለድም
      host: users[2],
      meetup_time: 32.days.from_now + 1.hour,
      meetup_location: meetup_locations[0],
      max_capacity: 15
    },
    {
      book_club: created_clubs[1],
      book: created_books[9], # የቀን መሐሪ
      host: users[1],
      meetup_time: 35.days.from_now + 3.hours,
      meetup_location: meetup_locations[1],
      max_capacity: 25
    }
  ]

  created_reads = reads_data.map do |rdata|
    BookRead.create!(rdata)
  end

  # 6. RSVPs for book reads
  puts "🎟️ Creating RSVPs..."
  created_reads.each do |bread|
    BookReadRsvp.find_or_create_by!(book_read: bread, user: bread.host) do |rsvp|
      rsvp.status = :going
    end

    users.sample(3).each do |u|
      next if u == bread.host
      BookReadRsvp.find_or_create_by!(book_read: bread, user: u) do |rsvp|
        rsvp.status = :going
      end
    end
  end

  puts "🎉 Seeding complete!"
  puts "📊 Stats: #{User.count} users, #{Book.count} books, #{BookClub.count} clubs, #{BookRead.count} book reads, #{BookReadRsvp.count} RSVPs."
end
