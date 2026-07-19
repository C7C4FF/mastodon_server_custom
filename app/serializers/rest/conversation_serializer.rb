# frozen_string_literal: true

class REST::ConversationSerializer < ActiveModel::Serializer
  attributes :id, :title, :unread, :unread_count

  has_many :participant_accounts, key: :accounts, serializer: REST::AccountSerializer
  has_one :last_status, serializer: REST::StatusSerializer

  def id
    object.id.to_s
  end

  def unread_count
    object.unread_count.to_i
  end

  def title
    object.respond_to?(:title) ? object.title : object.conversation.title
  end
end
