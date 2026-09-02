class DeviseCustomMailer < Devise::Mailer
  helper :application # gives access to app_name helper

  def confirmation_instructions(record, token, opts = {})
    opts[:subject] = "Welcome to #{Rails.configuration.x.app_name}! Please confirm your email"
    super
  end

  def reset_password_instructions(record, token, opts = {})
    opts[:subject] = "Reset your #{Rails.configuration.x.app_name} password"
    super
  end
end
