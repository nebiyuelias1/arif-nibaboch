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

  test "returns nil author when delimiter missing" do
    result = BookLookup::Parser.parse("Dune")

    assert_equal "Dune", result[:title]
    assert_nil result[:author]
  end
end
