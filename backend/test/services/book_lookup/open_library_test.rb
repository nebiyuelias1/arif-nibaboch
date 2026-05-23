require "test_helper"

class OpenLibraryTest < ActiveSupport::TestCase
  class FakeResponse
    attr_reader :body

    def initialize(body)
      @body = body
    end

    def is_a?(klass)
      klass == Net::HTTPSuccess
    end
  end

  test "maps open library search results" do
    payload = {
      "docs" => [
        {
          "title" => "Dune",
          "author_name" => ["Frank Herbert"],
          "first_sentence" => "In the week before their departure to Arrakis...",
          "cover_i" => 12345,
          "isbn" => ["9780441013593"],
          "publisher" => ["Ace"],
          "first_publish_year" => 1965,
          "number_of_pages_median" => 412,
          "subject" => ["Science fiction"],
          "key" => "/works/OL262758W"
        }
      ]
    }

    response = FakeResponse.new(payload.to_json)
    fake_http = Object.new
    fake_http.define_singleton_method(:request) { |_req| response }

    Net::HTTP.stub(:start, ->(*_args, &blk) { blk.call(fake_http) }) do
      provider = BookLookup::Providers::OpenLibrary.new(title: "Dune", author: "Frank Herbert", max_candidates: 1)
      results = provider.search

      assert_equal 1, results.size
      result = results.first
      assert_equal "Dune", result.title
      assert_equal "Frank Herbert", result.author
      assert_equal "In the week before their departure to Arrakis...", result.description
      assert_equal "https://covers.openlibrary.org/b/id/12345-L.jpg", result.cover_image
      assert_equal "9780441013593", result.isbn
      assert_equal "Ace", result.publisher
      assert_equal Date.new(1965, 1, 1), result.published_at
      assert_equal 412, result.page_count
      assert_equal ["Science fiction"], result.categories
      assert_equal "open_library", result.source
      assert_equal "https://openlibrary.org/works/OL262758W", result.source_url
    end
  end
end
