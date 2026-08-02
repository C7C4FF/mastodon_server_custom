# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Statuses Contexts' do
  describe 'GET /api/v1/statuses/:status_id/context' do
    context 'with an oauth token' do
      let(:user) { Fabricate(:user) }
      let(:client_app) { Fabricate(:application, name: 'Test app', website: 'http://testapp.com') }
      let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, application: client_app, scopes: scopes) }
      let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

      let(:scopes) { 'read:statuses' }

      context 'with a public status' do
        let(:status) { Fabricate(:status, account: user.account) }

        before { Fabricate(:status, account: user.account, thread: status) }

        it 'returns http success' do
          get "/api/v1/statuses/#{status.id}/context", headers: headers

          expect(response)
            .to have_http_status(200)
          expect(response.media_type)
            .to eq('application/json')
          expect(response.parsed_body)
            .to include(ancestors: be_an(Array).and(be_empty))
            .and include(descendants: be_an(Array).and(be_present))
        end
      end

      context 'with a public status that is a reply' do
        let(:status) { Fabricate(:status, account: user.account, thread: Fabricate(:status)) }

        before { Fabricate(:status, account: user.account, thread: status) }

        it 'returns http success' do
          get "/api/v1/statuses/#{status.id}/context", headers: headers

          expect(response)
            .to have_http_status(200)
          expect(response.media_type)
            .to eq('application/json')
          expect(response.parsed_body)
            .to include(ancestors: be_an(Array).and(be_present))
            .and include(descendants: be_an(Array).and(be_present))
        end
      end

      context 'with a direct conversation' do
        let(:other_user) { Fabricate(:user) }
        let!(:first_status) { PostStatusService.new.call(other_user.account, text: "First @#{user.account.username}", visibility: :direct) }
        let!(:status) { PostStatusService.new.call(user.account, text: "Second @#{other_user.account.username}", visibility: :direct, thread: first_status) }
        let!(:last_status) { PostStatusService.new.call(other_user.account, text: "Third @#{user.account.username}", visibility: :direct, thread: status) }

        it 'returns the conversation in the standard context fields', :aggregate_failures do
          get "/api/v1/statuses/#{status.id}/context", headers: headers

          body = response.parsed_body

          expect(response).to have_http_status(200)
          expect(body[:ancestors].pluck(:id)).to eq([first_status.id.to_s])
          expect(body[:descendants].pluck(:id)).to eq([last_status.id.to_s])
          expect(body).to_not have_key(:direct_messages)
        end
      end
    end

    context 'without an oauth token' do
      context 'with a public status' do
        let(:status) { Fabricate(:status, visibility: :public) }

        before { Fabricate(:status, thread: status) }

        it 'returns http success' do
          get "/api/v1/statuses/#{status.id}/context"

          expect(response)
            .to have_http_status(200)
          expect(response.media_type)
            .to eq('application/json')
          expect(response.parsed_body)
            .to include(ancestors: be_an(Array).and(be_empty))
            .and include(descendants: be_an(Array).and(be_present))
        end
      end

      context 'with a public status that is a reply' do
        let(:status) { Fabricate(:status, visibility: :public, thread: Fabricate(:status)) }

        before { Fabricate(:status, thread: status) }

        it 'returns http success' do
          get "/api/v1/statuses/#{status.id}/context"

          expect(response)
            .to have_http_status(200)
          expect(response.media_type)
            .to eq('application/json')
          expect(response.parsed_body)
            .to include(ancestors: be_an(Array).and(be_present))
            .and include(descendants: be_an(Array).and(be_present))
        end
      end
    end
  end
end
