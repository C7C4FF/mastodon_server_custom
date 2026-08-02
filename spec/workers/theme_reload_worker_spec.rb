# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ThemeReloadWorker do
  subject { described_class.new.perform }

  let(:account) { Fabricate(:account) }

  before do
    allow(FeedManager.instance).to receive(:with_active_accounts).and_yield(account)
    allow(redis).to receive(:exists?).with("subscribed:timeline:#{account.id}").and_return(true)
    allow(redis).to receive(:publish)
  end

  it 'reloads connected accounts' do
    subject

    expect(redis).to have_received(:publish).with("timeline:#{account.id}", '{"event":"force_reload","payload":"reload"}')
  end
end
