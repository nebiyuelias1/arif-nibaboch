class BookLookupJob < ApplicationJob
  queue_as :default

  def perform(title, author = nil)
    return if title.blank?

    result = BookLookup.find(title: title, author: author)
    return if result.blank? || result.title.blank?

    record = find_existing_book(result)
    attributes = build_attributes(result)

    if record
      record.update(attributes.compact_blank)
      record
    else
      puts "#attribes: #{attributes}"
      Book.create!(attributes)
    end
  end

  private

  def find_existing_book(result)
    return Book.find_by(isbn: result.isbn) if result.isbn.present?

    if result.author.present?
      Book.find_by(title: result.title, author: result.author)
    else
      Book.find_by(title: result.title)
    end
  end

  def build_attributes(result)
    {
      title: result.title,
      author: result.author,
      description: result.description,
      cover_image: result.cover_image,
      isbn: result.isbn,
      publisher: result.publisher,
      published_at: result.published_at,
      page_count: result.page_count,
      source: result.source,
      source_url: result.source_url
    }
  end
end
