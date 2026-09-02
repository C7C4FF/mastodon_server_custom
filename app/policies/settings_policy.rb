# frozen_string_literal: true

class SettingsPolicy < ApplicationPolicy
  def update?
    role.can?(:manage_settings)
  end

  def show?
    role.can?(:manage_settings)
  end

  def destroy?
    role.can?(:manage_settings)
  end

  def manage_branding_assets?
    role.can?(:manage_settings) && role.can?(:manage_branding_assets)
  end
end
