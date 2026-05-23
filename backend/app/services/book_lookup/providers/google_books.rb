require "net/http"
require "uri"

module BookLookup
  module Providers
    class GoogleBooks
      GOOGLE_BOOKS_URL = "https://www.googleapis.com/books/v1/volumes"

      def initialize(title:, author:, max_candidates:)
        @title = title
        @author = author
        @max_candidates = max_candidates
        @api_key = ENV["GOOGLE_BOOKS_API_KEY"]
      end

      def search
        return [] if @title.blank?

        uri = URI(GOOGLE_BOOKS_URL)
        uri.query = URI.encode_www_form(query_params)

        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, read_timeout: 10, open_timeout: 5) do |http|
          http.request(Net::HTTP::Get.new(uri))
        end

        unless response.is_a?(Net::HTTPSuccess)
          Rails.logger.warn(
            "GoogleBooks lookup failed: status=#{response.code} body=#{response.body.to_s[0, 500]}"
          )
          return []
        end

        data = JSON.parse(response.body)
        items = data.fetch("items", [])

        items.map { |item| build_result(item) }.compact
      rescue StandardError => e
        Rails.logger.error("GoogleBooks lookup error: #{e.message}")
        []
      end

      private

      def query_params
        parts = []
        parts << "intitle:#{@title}" if @title.present?
        parts << "inauthor:#{@author}" if @author.present?

        params = {
          q: parts.join("+"),
          maxResults: @max_candidates
        }
        params[:key] = @api_key if @api_key.present?
        params
      end

      def build_result(item)
        volume = item.fetch("volumeInfo", {})

        BookLookup::Result.new(
          title: volume["title"],
          author: Array(volume["authors"]).join(", "),
          description: volume["description"],
          cover_image: normalize_image_url(volume.dig("imageLinks", "thumbnail")),
          isbn: extract_isbn(volume["industryIdentifiers"]),
          publisher: volume["publisher"],
          published_at: parse_published_at(volume["publishedDate"]),
          page_count: volume["pageCount"],
          categories: volume["categories"],
          source: "google_books",
          source_url: volume["infoLink"],
          confidence: nil,
          candidates: nil
        )
      end

      def extract_isbn(identifiers)
        return nil if identifiers.blank?

        identifiers = Array(identifiers)
        isbn_13 = identifiers.find { |identifier| identifier["type"] == "ISBN_13" }
        isbn_10 = identifiers.find { |identifier| identifier["type"] == "ISBN_10" }
        isbn_13&.dig("identifier") || isbn_10&.dig("identifier")
      end

      def parse_published_at(value)
        return nil if value.blank?

        if value.match?(/^\d{4}$/)
          Date.new(value.to_i, 1, 1)
        elsif value.match?(/^\d{4}-\d{2}$/)
          Date.new(value[0, 4].to_i, value[5, 2].to_i, 1)
        else
          Date.parse(value)
        end
      rescue ArgumentError
        nil
      end

      def normalize_image_url(url)
        return nil if url.blank?

        url.start_with?("http://") ? url.sub("http://", "https://") : url
      end
    end
  end
end
