# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Conversations' do
  include_context 'with API authentication', oauth_scopes: 'read:statuses write:conversations'

  let!(:user) { Fabricate(:user, account_attributes: { username: 'alice' }) }

  let(:other) { Fabricate(:user) }

  describe 'GET /api/v1/conversations', :inline_jobs do
    before do
      user.account.follow!(other.account)
      PostStatusService.new.call(other.account, text: 'Hey @alice', visibility: 'direct')
      PostStatusService.new.call(user.account, text: 'Hey, nobody here', visibility: 'direct')
    end

    it 'returns pagination headers', :aggregate_failures do
      get '/api/v1/conversations', params: { limit: 1 }, headers: headers

      expect(response)
        .to have_http_status(200)
        .and include_pagination_headers(
          prev: api_v1_conversations_url(limit: 1, min_id: Status.first.id),
          next: api_v1_conversations_url(limit: 1, max_id: Status.first.id)
        )
      expect(response.content_type)
        .to start_with('application/json')
    end

    it 'returns conversations', :aggregate_failures do
      get '/api/v1/conversations', headers: headers

      expect(response.parsed_body.size).to eq 2
      expect(response.parsed_body.first[:accounts].size).to eq 1
    end

    it 'keeps group conversations from anonymized deleted accounts', :aggregate_failures do
      third_user = Fabricate(:user, account_attributes: { username: 'charlie' })
      status = PostStatusService.new.call(other.account, text: 'Hey @alice @charlie', visibility: 'direct')
      deleted_account_id = other.account_id
      deleted_user_id = other.id

      other.account.suspend!(origin: :local, block_email: false)

      get "/api/v1/statuses/#{status.id}", headers: headers
      expect(response).to have_http_status(:success)

      get "/api/v1/statuses/#{status.id}/context", headers: headers
      expect(response).to have_http_status(:success)

      AccountDeletionWorker.new.perform(deleted_account_id, { 'preserve_content' => true, 'skip_activitypub' => true })

      get '/api/v1/conversations', headers: headers

      conversation = response.parsed_body.find { |item| item.dig(:last_status, :id) == status.id.to_s }
      expect(conversation).to be_present
      expect(conversation[:accounts]).to include(
        hash_including(username: 'deleted', acct: 'deleted', display_name: '탈퇴한 사용자', suspended: true),
        hash_including(id: third_user.account_id.to_s)
      )
      expect(Account.find(deleted_account_id)).to be_anonymized
      expect(User.exists?(deleted_user_id)).to be false

      get "/api/v1/statuses/#{status.id}", headers: headers
      expect(response).to have_http_status(:success)

      get "/api/v1/statuses/#{status.id}/context", headers: headers
      expect(response).to have_http_status(:success)
    end

    context 'with since_id' do
      context 'when requesting old posts' do
        it 'returns conversations' do
          get '/api/v1/conversations', params: { since_id: Mastodon::Snowflake.id_at(1.hour.ago, with_random: false) }, headers: headers

          expect(response.parsed_body.size).to eq 2
        end
      end

      context 'when requesting posts in the future' do
        it 'returns no conversation' do
          get '/api/v1/conversations', params: { since_id: Mastodon::Snowflake.id_at(1.hour.from_now, with_random: false) }, headers: headers

          expect(response.parsed_body.size).to eq 0
        end
      end
    end
  end

  describe 'PATCH /api/v1/conversations/title', :inline_jobs do
    let!(:status) do
      user.account.follow!(other.account)
      PostStatusService.new.call(other.account, text: 'Hey @alice', visibility: 'direct')
    end

    it 'updates the shared conversation title' do
      account_conversation = AccountConversation.find_by!(account: user.account, conversation_id: status.conversation_id)

      patch '/api/v1/conversations/title',
            params: { conversation_id: status.conversation_id, title: 'Ravenclaw group' },
            headers: headers

      expect(response).to have_http_status(200)
      expect(response.parsed_body[:title]).to eq('Ravenclaw group')
      expect(account_conversation.conversation.reload.title).to eq('Ravenclaw group')
      title_change = Status.order(id: :desc).first
      expect(title_change).to have_attributes(
        account: user.account,
        conversation_id: status.conversation_id,
        text: include("alice님의 변경. 'Ravenclaw group'")
      )

      get "/api/v1/statuses/#{title_change.id}", headers: headers

      expect(response.parsed_body).to include(
        sensitive: false,
        spoiler_text: '',
        conversation_event: { type: 'title_changed', text: "alice님의 변경. 'Ravenclaw group'" }
      )
    end

    it 'does not update a conversation the current account does not participate in' do
      private_conversation = Fabricate(:conversation)

      patch '/api/v1/conversations/title',
            params: { conversation_id: private_conversation.id, title: 'Not mine' },
            headers: headers

      expect(response).to have_http_status(404)
      expect(private_conversation.reload.title).to be_nil
    end
  end
end
