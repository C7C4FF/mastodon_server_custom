# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings Preferences Appearance' do
  describe 'PUT /settings/preferences/appearance' do
    let(:user) { Fabricate(:user, locale: 'en') }

    before { sign_in user }

    it 'updates the interface language' do
      put settings_preferences_appearance_path, params: { user: { locale: 'ko' } }

      expect(response).to redirect_to(settings_preferences_appearance_path)
      expect(user.reload.locale).to eq('ko')
    end

    it 'gracefully handles invalid nested params' do
      put settings_preferences_appearance_path(user: 'invalid')

      expect(response)
        .to have_http_status(400)
    end
  end
end
