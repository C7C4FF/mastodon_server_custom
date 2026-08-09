# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Auth Account Switcher' do
  let(:primary_user) { Fabricate(:user) }
  let(:switchable_user) { Fabricate(:user) }

  it 'keeps switchable accounts after the browser session cookie is removed' do
    sign_in_with_switchable_account(primary_user, switchable_user)

    expect(Array(response.headers['Set-Cookie']).join("\n"))
      .to include('_mastodon_switchable_account_user_ids=', 'expires=', 'httponly')

    cookies.delete('_mastodon_session')
    get auth_account_switcher_path(format: :json)

    expect(response.parsed_body[:accounts].pluck(:id))
      .to contain_exactly(primary_user.account_id.to_s, switchable_user.account_id.to_s)
  end
end
