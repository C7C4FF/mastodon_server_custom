# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CustomBrandingTheme do
  describe '.css_for' do
    it 'emits independent profile field card background and opacity variables' do
      css = described_class.css_for(
        described_class::DEFAULTS.merge(
          branding_color_profile_field_card_background: '#112233',
          branding_color_profile_field_card_background_light: '#ddeeff',
          branding_profile_field_card_opacity: 45
        )
      )

      expect(css).to include('--custom-profile-field-card-background: #112233;')
      expect(css).to include('--custom-profile-field-card-background: #ddeeff;')
      expect(css).to include('--custom-profile-field-card-opacity: 45%;')
      expect(css).to include("html[data-color-scheme='dark'] body.has-custom-public-background-dark")
      expect(css).to include("html[data-color-scheme='light'] body.has-custom-public-background-light")
    end
  end
end
