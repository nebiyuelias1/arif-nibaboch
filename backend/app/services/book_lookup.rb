module BookLookup
  def self.find(title:, author: nil)
    Finder.new(title:, author:, max_candidates: 1).find&.first
  end

  def self.find_many(title:, author: nil)
    Finder.new(title:, author:, max_candidates: 10).find
  end
end
