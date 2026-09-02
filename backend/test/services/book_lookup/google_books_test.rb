require "test_helper"

class GoogleBooksTest < ActiveSupport::TestCase
  class FakeResponse
    attr_reader :body

    def initialize(body, success: true)
      @body = body
      @success = success
    end

    def is_a?(klass)
      return @success if klass == Net::HTTPSuccess

      super
    end
  end

  test "maps google books search results" do
    payload = {
      "items" => [
        {
          "volumeInfo" => {
            "title" => "Dune",
            "authors" => [ "Frank Herbert" ],
            "description" => "Science fiction classic",
            "imageLinks" => { "thumbnail" => "http://example.com/image.jpg&edge=curl&zoom=1" },
            "industryIdentifiers" => [ { "type" => "ISBN_13", "identifier" => "9780441172719" } ],
            "publisher" => "Ace",
            "publishedDate" => "1965",
            "pageCount" => 412,
            "categories" => [ "Science fiction" ],
            "infoLink" => "https://books.google.com/books/about/Dune"
          }
        }
      ]
    }

    response = FakeResponse.new(payload.to_json)
    fake_http = Object.new
    fake_http.define_singleton_method(:request) { |_req| response }

    Net::HTTP.stub(:start, ->(*_args, &blk) { blk.call(fake_http) }) do
      provider = BookLookup::Providers::GoogleBooks.new(title: "Dune", author: "Frank Herbert", max_candidates: 1)
      results = provider.search

      assert_equal 1, results.size
      result = results.first
      assert_equal "Dune", result.title
      assert_equal "Frank Herbert", result.author
      assert_equal "Science fiction classic", result.description
      assert_equal "https://example.com/image.jpg&zoom=2", result.cover_image
      assert_equal "9780441172719", result.isbn
      assert_equal "Ace", result.publisher
      assert_equal Date.new(1965, 1, 1), result.published_at
      assert_equal 412, result.page_count
      assert_equal [ "Science fiction" ], result.categories
      assert_equal "google_books", result.source
      assert_equal "https://books.google.com/books/about/Dune", result.source_url
    end
  end

  test "returns empty array when circuit is open" do
    provider = BookLookup::Providers::GoogleBooks.new(title: "Dune", author: "Frank Herbert", max_candidates: 1)
    fake_stoplight = Object.new
    fake_stoplight.define_singleton_method(:run) do |fallback, &_block|
      fallback.call(nil)
    end

    provider.stub(:stoplight, fake_stoplight) do
      assert_equal [], provider.search
    end
  end
end
