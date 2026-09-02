# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SettingsPolicy do
  subject { described_class }

  let(:admin)   { Fabricate(:admin_user).account }
  let(:john)    { Fabricate(:account) }

  permissions :update?, :show?, :destroy? do
    context 'when admin?' do
      it 'permits' do
        expect(subject).to permit(admin, Settings)
      end
    end

    context 'with !admin?' do
      it 'denies' do
        expect(subject).to_not permit(john, Settings)
      end
    end
  end

  permissions :manage_branding_assets? do
    let(:settings_only) do
      Fabricate(:user, role: Fabricate(:user_role, permissions: UserRole::FLAGS[:manage_settings])).account
    end

    it { is_expected.to permit(admin, Settings) }
    it { is_expected.to_not permit(settings_only, Settings) }
  end
end
