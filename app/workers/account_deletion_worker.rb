# frozen_string_literal: true

class AccountDeletionWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', lock: :until_executed, lock_ttl: 1.week.to_i

  def perform(account_id, options = {})
    account = Account.find(account_id)
    return unless account.unavailable?

    options = options.with_indifferent_access
    reserve_username = options.fetch(:reserve_username, true)
    skip_activitypub = options.fetch(:skip_activitypub, false)
    preserve_content = options.fetch(:preserve_content, false)
    DeleteAccountService.new.call(account, reserve_username: reserve_username, skip_activitypub: skip_activitypub, reserve_email: false, preserve_content: preserve_content)
  rescue ActiveRecord::RecordNotFound
    true
  end
end
