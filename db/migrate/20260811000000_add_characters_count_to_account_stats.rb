# frozen_string_literal: true

class AddCharactersCountToAccountStats < ActiveRecord::Migration[8.1]
  def change
    add_column :account_stats, :characters_count, :bigint, default: 0, null: false
  end
end
