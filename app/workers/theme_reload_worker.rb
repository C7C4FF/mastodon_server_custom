# frozen_string_literal: true

class ThemeReloadWorker
  include Sidekiq::Worker
  include Redisable

  def perform
    payload = { event: :force_reload, payload: 'reload' }.to_json

    FeedManager.instance.with_active_accounts do |account|
      redis.publish("timeline:#{account.id}", payload) if redis.exists?("subscribed:timeline:#{account.id}")
    end
  end
end
