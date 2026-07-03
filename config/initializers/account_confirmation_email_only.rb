# frozen_string_literal: true

Rails.application.configure do
  configured_value = config.x.account_confirmation_email_only

  config.x.account_confirmation_email_only =
    if ENV.key?('ACCOUNT_CONFIRMATION_EMAIL_ONLY')
      ActiveModel::Type::Boolean.new.cast(ENV['ACCOUNT_CONFIRMATION_EMAIL_ONLY'])
    elsif configured_value.nil?
      true
    else
      configured_value
    end
end
