# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin theme' do
  include_context 'with API authentication', oauth_scopes: 'write'

  before { Setting.force_dark_theme = false }

  describe 'PATCH /api/v1/admin/theme' do
    it 'rejects a regular user' do
      patch '/api/v1/admin/theme', headers: headers

      expect(response).to have_http_status(403)
      expect(Setting.force_dark_theme).to be(false)
    end

    context 'when the user can view the admin dashboard' do
      let(:user) { Fabricate(:moderator_user) }

      it 'toggles the theme and reloads connected users' do
        patch '/api/v1/admin/theme', headers: headers

        expect(response).to have_http_status(200)
        expect(Setting.force_dark_theme).to be(true)

        patch '/api/v1/admin/theme', headers: headers

        expect(response).to have_http_status(200)
        expect(Setting.force_dark_theme).to be(false)
        expect(ThemeReloadWorker).to have_enqueued_sidekiq_job.exactly(2).times
      end
    end
  end
end
