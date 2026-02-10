require "test_helper"

class TbrItemTest < ActiveSupport::TestCase
  test "should belong to user and book" do
    tbr_item = tbr_items(:one)
    assert_not_nil tbr_item.user
    assert_not_nil tbr_item.book
  end

  test "should not allow duplicate tbr_items for same user and book" do
    user = users(:one)
    book = books(:one)
    
    # First TBR item should save
    tbr_item1 = TbrItem.new(user: user, book: book)
    assert tbr_item1.save
    
    # Duplicate should not save
    tbr_item2 = TbrItem.new(user: user, book: book)
    assert_not tbr_item2.save
    assert_includes tbr_item2.errors[:user_id], "has already added this book to TBR"
  end

  test "should allow same book in different users' TBR lists" do
    user1 = users(:one)
    user2 = users(:two)
    book = books(:three)
    
    tbr_item1 = TbrItem.create(user: user1, book: book)
    tbr_item2 = TbrItem.create(user: user2, book: book)
    
    assert tbr_item1.valid?
    assert tbr_item2.valid?
  end

  test "should allow same user to have multiple books in TBR" do
    user = users(:one)
    book1 = books(:two)
    book2 = books(:three)
    
    tbr_item1 = TbrItem.create(user: user, book: book1)
    tbr_item2 = TbrItem.create(user: user, book: book2)
    
    assert tbr_item1.valid?
    assert tbr_item2.valid?
  end
end
