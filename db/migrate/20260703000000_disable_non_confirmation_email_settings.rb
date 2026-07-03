# frozen_string_literal: true

class DisableNonConfirmationEmailSettings < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  class User < ApplicationRecord; end

  NOTIFICATION_EMAIL_SETTINGS = %w(
    notification_emails.follow
    notification_emails.reblog
    notification_emails.favourite
    notification_emails.mention
    notification_emails.quote
    notification_emails.follow_request
    notification_emails.report
    notification_emails.pending_account
    notification_emails.trends
    notification_emails.appeal
  ).freeze

  def up
    User.find_each do |user|
      settings = settings_for(user)

      NOTIFICATION_EMAIL_SETTINGS.each do |key|
        settings[key] = false
      end

      settings['notification_emails.software_updates'] = 'none'
      settings['always_send_emails'] = false
      settings['email_subscriptions'] = false

      user.update_column('settings', JSON.generate(settings))
    end
  end

  def down; end

  private

  def settings_for(user)
    raw_settings = user.attributes_before_type_cast['settings']
    return {} if raw_settings.blank?

    JSON.parse(raw_settings) || {}
  end
end
