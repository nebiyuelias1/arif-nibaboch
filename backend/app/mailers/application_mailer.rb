class ApplicationMailer < ActionMailer::Base
  default from: "noreply@#{Rails.configuration.x.domain}"
  layout "mailer"
end
