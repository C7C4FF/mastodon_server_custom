# frozen_string_literal: true

class AddManageBrandingAssetsPermission < ActiveRecord::Migration[8.1]
  MANAGE_SETTINGS_PERMISSION = 1 << 6
  MANAGE_BRANDING_ASSETS_PERMISSION = 1 << 23

  def up
    safety_assured do
      execute <<~SQL.squish
        UPDATE user_roles
        SET permissions = permissions | #{MANAGE_BRANDING_ASSETS_PERMISSION}
        WHERE permissions & #{MANAGE_SETTINGS_PERMISSION} != 0
      SQL
    end
  end

  def down
    safety_assured do
      execute <<~SQL.squish
        UPDATE user_roles
        SET permissions = permissions & ~#{MANAGE_BRANDING_ASSETS_PERMISSION}
      SQL
    end
  end
end
