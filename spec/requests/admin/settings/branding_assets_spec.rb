# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Settings Branding Assets' do
  context 'when the user can manage settings but not branding assets' do
    let(:role) { Fabricate(:user_role, permissions: UserRole::FLAGS[:manage_settings]) }

    before { sign_in Fabricate(:user, role: role) }

    it 'allows other settings but denies direct access to branding assets' do
      get admin_settings_branding_path

      expect(response).to have_http_status(200)

      get admin_settings_branding_assets_path

      expect(response).to have_http_status(403)
    end
  end
end
