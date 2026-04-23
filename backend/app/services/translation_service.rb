require "net/http"

class TranslationService
  def initialize(text, target_lang: "ZH")
    @text = text
    @target_lang = target_lang
    @api_key = ENV["DEEPL_AUTH_KEY"] || Rails.application.credentials.deepl_auth_key
  end

  def call
    return nil if @text.blank? || @api_key.blank?

    uri = URI("https://api-free.deepl.com/v2/translate")

    # DeepL API accepts x-www-form-urlencoded format
    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = "DeepL-Auth-Key #{@api_key}"
    request.set_form_data({
      "text" => @text,
      "target_lang" => @target_lang
    })

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      data.dig("translations", 0, "text")
    else
      Rails.logger.error("TranslationService Error: #{response.code} - #{response.body}")
      nil
    end
  rescue => e
    Rails.logger.error("TranslationService Exception: #{e.message}")
    nil
  end
end
