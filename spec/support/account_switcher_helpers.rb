# frozen_string_literal: true

module AccountSwitcherHelpers
  def sign_in_with_switchable_account(primary_user, switchable_user)
    post user_session_path, params: { user: { email: primary_user.email, password: primary_user.password } }
    post '/auth/account_switcher/add'
    post user_session_path, params: { user: { email: switchable_user.email, password: switchable_user.password } }
    post '/auth/account_switcher/switch', params: { account_id: primary_user.account_id }
  end
end

RSpec.configure do |config|
  config.include AccountSwitcherHelpers, type: :request
end
