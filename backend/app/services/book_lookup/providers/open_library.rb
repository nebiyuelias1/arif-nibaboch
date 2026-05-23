require "net/http"
require "uri"

module BookLookup
  module Providers
    class OpenLibrary
      OPEN_LIBRARY_URL = "https://openlibrary.org/search.json"

      def initialize(title:, author:, max_candidates:)
        @title = title
        @author = author
        @max_candidates = max_candidates
      end

      def search
        return [] if @title.blank?

        uri = URI(OPEN_LIBRARY_URL)
        uri.query = URI.encode_www_form(query_params)

        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, read_timeout: 10, open_timeout: 5) do |http|
          http.request(Net::HTTP::Get.new(uri))
        end

        return [] unless response.is_a?(Net::HTTPSuccess)

        data = JSON.parse(response.body)
        docs = data.fetch("docs", [])

        docs.map { |doc| build_result(doc) }.compact
      rescue StandardError => e
        Rails.logger.error("OpenLibrary lookup error: #{e.message}")
        []
      end

      private

      def query_params
        params = {
          title: @title,
          limit: @max_candidates
        }
        params[:author] = @author if @author.present?
        params
      end

      def build_result(doc)
        BookLookup::Result.new(
          title: doc["title"],
          author: Array(doc["author_name"]).join(", "),
          description: extract_description(doc),
          cover_image: cover_url(doc["cover_i"]),
          isbn: Array(doc["isbn"]).first,
          publisher: Array(doc["publisher"]).first,
          published_at: parse_published_at(doc["first_publish_year"]),
          page_count: doc["number_of_pages_median"],
          categories: doc["subject"],
          source: "open_library",
          source_url: open_library_url(doc["key"]),
          confidence: nil,
          candidates: nil
        )
      end

      def extract_description(doc)
        first_sentence = doc["first_sentence"]
        return first_sentence if first_sentence.is_a?(String)
        return first_sentence.first if first_sentence.is_a?(Array)

        nil
      end

      def parse_published_at(value)
        return nil if value.blank?

        Date.new(value.to_i, 1, 1)
      rescue ArgumentError
        nil
      end

      def cover_url(cover_id)
        return nil if cover_id.blank?

        "https://covers.openlibrary.org/b/id/#{cover_id}-L.jpg"
      end

      def open_library_url(key)
        return nil if key.blank?

        "https://openlibrary.org#{key}"
      end
    end
  end
end
