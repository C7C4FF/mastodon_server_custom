# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::NotificationSerializer do
  subject do
    serialized_record_json(
      notification,
      described_class,
      options: {
        scope: current_user,
        scope_name: :current_user,
        supported_notification_types: [],
      }
    )
  end

  let(:current_user) { Fabricate(:user) }
  let(:notification) { Fabricate :notification }

  context 'when created_at is populated' do
    it 'parses as RFC 3339 datetime' do
      expect(subject)
        .to include(
          'created_at' => match_api_datetime_format
        )
    end
  end

  context 'with a mention notification' do
    let(:notification) { Fabricate(:notification, type: :mention, activity: Fabricate(:mention), account: current_user.account) }

    before do
      notification.from_account.account_stat.update!(characters_count: 123)
    end

    it 'includes the sender lifetime character count' do
      expect(subject.dig('account', 'characters_count')).to eq(123)
    end
  end

  shared_examples 'with fallback notifications' do |type, fabricator|
    let(:notification) { Fabricate(:notification, type:, activity: Fabricate(fabricator), account: current_user.account) }

    it 'renders correctly' do
      expect(subject)
        .to include(
          'type' => type,
          'fallback' => include(
            'title' => anything,
            'summary' => anything
          )
        )
    end
  end

  it_behaves_like 'with fallback notifications', 'severed_relationships', :account_relationship_severance_event
  it_behaves_like 'with fallback notifications', 'moderation_warning', :account_warning
  it_behaves_like 'with fallback notifications', 'admin.report', :report
  it_behaves_like 'with fallback notifications', 'added_to_collection', :collection_item
  it_behaves_like 'with fallback notifications', 'collection_update', :collection
end
