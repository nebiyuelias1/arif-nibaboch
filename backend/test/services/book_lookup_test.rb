require "test_helper"

class BookLookupTest < ActiveSupport::TestCase
  test "parses title and author separated by by" do
    result = BookLookup::Parser.parse("Dune BY Frank Herbert")

    assert_equal "Dune", result[:title]
    assert_equal "Frank Herbert", result[:author]
  end

  test "handles extra whitespace" do
    result = BookLookup::Parser.parse("  Dune   By   Frank Herbert  ")

    assert_equal "Dune", result[:title]
    assert_equal "Frank Herbert", result[:author]
  end


  test "handles by in book title" do
    result = BookLookup::Parser.parse("Living by the River By Florence Chuang")

    assert_equal "Living by the River", result[:title]
    assert_equal "Florence Chuang", result[:author]
  end

  test "returns nil author when delimiter missing" do
    result = BookLookup::Parser.parse("Dune")

    assert_equal "Dune", result[:title]
    assert_nil result[:author]
  end

  test "find returns first google books result" do
    result = BookLookup::Result.new(title: "Dune", author: "Frank Herbert")
    provider = Minitest::Mock.new
    provider.expect(:search, [ result ])

    BookLookup::Providers::GoogleBooks.stub(:new, provider) do
      assert_equal result, BookLookup.find(title: "Dune", author: "Frank Herbert")
    end

    provider.verify
  end
end
