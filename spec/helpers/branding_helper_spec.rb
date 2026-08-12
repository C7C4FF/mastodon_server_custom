# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BrandingHelper do
  describe '#custom_background_path' do
    it 'does not share theme-specific backgrounds across color schemes' do
      common = double(file: double(url: '/common.jpg'))
      light = double(file: double(url: '/light.jpg'))
      dark = double(file: double(url: '/dark.jpg'))
      presenter = double(background: common, background_light: light, background_dark: dark)

      allow(helper).to receive_messages(
        instance_presenter: presenter,
        request: double(content_security_policy_nonce: nil)
      )

      expect(helper.custom_background_path(:light)).to eq('/light.jpg')
      expect(helper.custom_background_path(:dark)).to eq('/dark.jpg')
      expect(helper.public_background_body_class).to eq('has-public-background has-custom-public-background-light has-custom-public-background-dark')

      allow(presenter).to receive_messages(background_light: nil, background_dark: nil)

      expect(helper.custom_background_path(:light)).to eq('/common.jpg')
      expect(helper.custom_background_path(:dark)).to eq('/common.jpg')

      allow(presenter).to receive_messages(background: nil, background_dark: dark)

      expect(helper.custom_background_path(:light)).to be_nil
      expect(helper.custom_background_path(:dark)).to eq('/dark.jpg')
      expect(helper.public_background_body_class).to eq('has-public-background has-custom-public-background-dark')

      expect(helper.public_background_stylesheet).to include('--custom-public-background-image-light: none')
    end
  end
end
