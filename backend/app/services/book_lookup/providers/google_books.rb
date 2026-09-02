require "net/http"
require "uri"

module BookLookup
  module Providers
    class GoogleBooks
      GOOGLE_BOOKS_URL = "https://www.googleapis.com/books/v1/volumes"
      ExternalServiceError = Class.new(StandardError)

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

        response = stoplight.run(method(:stoplight_fallback)) do
          request = Net::HTTP::Get.new(uri)
          response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, read_timeout: 10, open_timeout: 5) do |http|
            http.request(request)
          end

          if response.is_a?(Net::HTTPSuccess)
            response
          else
            raise ExternalServiceError, "status=#{response.code} body=#{response.body.to_s[0, 500]}"
          end
        end
        return [] if response.nil?

        data = JSON.parse(response.body)
        items = data.fetch("items", [])

        items.map { |item| build_result(item) }.compact
      rescue => e
        Rails.logger.error("GoogleBooks lookup error: #{e.message}")
        []
      end

      private

      def query_params
        q = [ @title, @author ].compact.uniq.join(" ")

        params = {
          q: q,
          orderBy: "relevance",
          printType: "books",
          maxResults: @max_candidates
        }
        params[:key] = @api_key if @api_key.present?
        params
      end

      def build_result(item)
        volume = item.fetch("volumeInfo", {})
        images = volume.fetch("imageLinks", {})

        # Try to get the largest available image
        image_url = images["extraLarge"] || images["large"] || images["medium"] ||
          images["small"] || images["thumbnail"] || images["smallThumbnail"]

        BookLookup::Result.new(
          title: volume["title"],
          author: Array(volume["authors"]).join(", "),
          description: volume["description"],
          cover_image: normalize_image_url(image_url),
          isbn: extract_isbn(volume["industryIdentifiers"]),
          publisher: volume["publisher"],
          published_at: parse_published_at(volume["publishedDate"]),
          page_count: volume["pageCount"],
          language: volume["language"],
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

        # Ensure HTTPS
        url = url.sub("http://", "https://")

        # Increase zoom level for better resolution
        # zoom=1 is thumbnail, zoom=2 or zoom=3 are higher quality
        url = url.sub("zoom=1", "zoom=2")

        # Remove 'edge=curl' which can add artificial shadow/curling to the image
        url.gsub("&edge=curl", "")
      end

      def stoplight
        @stoplight ||= Stoplight(
          "book_lookup/google_books",
          threshold: 3,
          cool_off_time: 60,
          tracked_errors: [
            ExternalServiceError,
            Net::OpenTimeout,
            Net::ReadTimeout,
            Timeout::Error,
            SocketError,
            Errno::ECONNRESET,
            Errno::ECONNREFUSED
          ]
        )
      end

      def stoplight_fallback(error)
        if error
          Rails.logger.warn("GoogleBooks lookup failed: #{error.message}")
        else
          Rails.logger.warn("GoogleBooks lookup skipped because circuit is open")
        end
        nil
      end
    end
  end
end
