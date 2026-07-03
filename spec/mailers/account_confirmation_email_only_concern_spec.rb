# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountConfirmationEmailOnlyConcern do
  around do |example|
    original_value = Rails.configuration.x.account_confirmation_email_only
    Rails.configuration.x.account_confirmation_email_only = true

    example.run
  ensure
    Rails.configuration.x.account_confirmation_email_only = original_value
  end

  let(:receiver) { Fabricate(:user) }

  it 'allows account confirmation instructions' do
    emails = capture_emails do
      UserMailer.confirmation_instructions(receiver, 'spec').deliver_now!
    end

    expect(emails.size).to eq 1
    expect(emails.first.subject).to eq I18n.t('devise.mailer.confirmation_instructions.subject', instance: Rails.configuration.x.local_domain)
  end

  it 'blocks reconfirmation instructions' do
    receiver.update!(unconfirmed_email: 'new-email@example.com')

    emails = capture_emails do
      UserMailer.confirmation_instructions(receiver, 'spec').deliver_now!
    end

    expect(emails).to be_empty
  end

  it 'blocks suspicious sign-in email even when deliver_now! is used' do
    emails = capture_emails do
      UserMailer.suspicious_sign_in(receiver, '192.0.2.1', 'NCSA_Mosaic/2.0', Time.now.utc).deliver_now!
    end

    expect(emails).to be_empty
  end
end
