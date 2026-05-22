module BookLookup
  module Parser
    def self.parse(text)
      parts = text.split(/\s+by\s+/i)
      { title: parts[0]&.strip, author: parts[1]&.strip }
    end
  end
end
