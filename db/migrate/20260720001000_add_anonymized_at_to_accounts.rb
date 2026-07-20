# frozen_string_literal: true

class AddAnonymizedAtToAccounts < ActiveRecord::Migration[8.1]
  def change
    add_column :accounts, :anonymized_at, :datetime
  end
end
