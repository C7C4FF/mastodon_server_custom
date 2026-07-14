# frozen_string_literal: true

class GrantInviteUsersToAdminRole < ActiveRecord::Migration[8.1]
  INVITE_USERS_PERMISSION = 1 << 16

  def up
    safety_assured do
      execute <<~SQL.squish
        UPDATE user_roles
        SET permissions = permissions | #{INVITE_USERS_PERMISSION}
        WHERE name = 'Admin'
      SQL
    end
  end

  def down
    safety_assured do
      execute <<~SQL.squish
        UPDATE user_roles
        SET permissions = permissions & ~#{INVITE_USERS_PERMISSION}
        WHERE name = 'Admin'
      SQL
    end
  end
end
