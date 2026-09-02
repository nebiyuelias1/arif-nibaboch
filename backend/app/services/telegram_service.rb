require "net/http"
require "uri"

class TelegramService
  BASE_URL = "https://api.telegram.org/bot"

  def initialize(book)
    @book = book
    @bot_token = ENV["TELEGRAM_BOT_TOKEN"]
    @channel_username = ENV["TELEGRAM_CHANNEL_USERNAME"]
  end

  def publish
    unless @bot_token && @channel_username
      Rails.logger.warn "Missing TELEGRAM_BOT_TOKEN and TELEGRAM_CHANNEL_USERNAME env variables."
      return
    end

    if @book.cover_image.present?
      post_photo_to_telegram_channel
    else
      post_to_telegram_channel
    end
  end

  private

  def post_photo_to_telegram_channel
    caption = get_caption

    params = {
      chat_id: "@#{@channel_username}",
      caption: caption,
      photo: @book.cover_image,
      parse_mode: "Markdown"
    }

    send_http_request("sendPhoto", params)
  end

  def post_to_telegram_channel
    caption = get_caption

    params = {
      chat_id: "@#{@channel_username}",
      caption: caption,
      parse_mode: "Markdown"
    }

    send_http_request("sendMessage", params)
  end

  def send_http_request(action, params)
    uri = URI("#{BASE_URL}#{@bot_token}/#{action}")

    response = Net::HTTP.post_form(uri, params)

    result = JSON.parse(response.body)

    if result["ok"]
      message_id = result["result"]["message_id"]
      Rails.logger.info "✅ Successfully posted Book to Telegram with message ID: #{message_id}"
      message_id
    else
      Rails.logger.error "❌ Failed to post to Telegram: #{result["description"]}"
      nil
    end
  rescue => e
    Rails.logger.error "❌ Telegram API Error: #{e.message}"
    nil
  end

  def get_caption
    # Caption with book details and a link back to the site
    # Note: You need to configure default_url_options in production for correct links
    <<~TEXT
      📖 *#{@book.title}*#{" "}
      by #{@book.author}#{" "}

      #{@book.description&.truncate(150)}#{" "}
    TEXT
  end
end
