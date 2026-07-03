# frozen_string_literal: true

module AccountConfirmationEmailOnlyConcern
  extend ActiveSupport::Concern

  included do
    before_deliver :abort_non_account_confirmation_email!
  end

  private

  def abort_non_account_confirmation_email!
    return unless Rails.configuration.x.account_confirmation_email_only
    return if account_confirmation_email?

    Rails.logger.info("Blocked #{self.class.name}##{action_name} email because account confirmation-only email mode is enabled")
    throw(:abort)
  end

  def account_confirmation_email?
    instance_of?(::UserMailer) &&
      action_name == 'confirmation_instructions' &&
      @resource.present? &&
      !@resource.pending_reconfirmation?
  end
end
