# frozen_string_literal: true

class AddPendingMentionDismissalToNotifications < ActiveRecord::Migration[8.1]
  def change
    add_column :notifications, :dismissed_from_pending_mentions_at, :datetime
  end
end
