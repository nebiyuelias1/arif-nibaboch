module BookLookup
  class Finder
    def initialize(title:, author:, max_candidates: 5)
      @title = title
      @author = author
      @max_candidates = max_candidates
    end

    def find
      providers = [
        BookLookup::Providers::GoogleBooks.new(
          title: @title,
          author: @author,
          max_candidates: @max_candidates
        )
        # TODO: Add open library provider
        # by scoring results and picking the
        # correct one, merging, confidence, etc.
        # BookLookup::Providers::OpenLibrary.new(
        #   title: @title,
        #   author: @author,
        #   max_candidates: @max_candidates
        # )
      ]

      providers.each do |provider|
        results = provider.search
        next if results.blank?

        return results.first(@max_candidates)
      end

      nil
    end
  end
end
