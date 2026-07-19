# frozen_string_literal: true

class AddTitleToConversations < ActiveRecord::Migration[8.1]
  def change
    add_column :conversations, :title, :string
  end
end
