module BookLookup
  module Parser
    def self.parse(text)
      parts = text.match(/(.*)\s+by\s+(.+)\z/i)
      if parts
        title = parts[1]&.strip
        author = parts[2]&.strip
      else
        title = text&.strip
        author = nil
      end
      { title: title, author: author }
    end
  end
end
