# frozen_string_literal: true

class Api::V1::ConversationsController < Api::BaseController
  LIMIT = 20

  before_action -> { doorkeeper_authorize! :read, :'read:statuses' }, only: :index
  before_action -> { doorkeeper_authorize! :write, :'write:conversations' }, except: :index
  before_action :require_user!
  before_action :set_conversation, except: [:index, :title]
  after_action :insert_pagination_headers, only: :index

  def index
    @conversations = paginated_conversations
    render json: @conversations, each_serializer: REST::ConversationSerializer, relationships: StatusRelationshipsPresenter.new(@conversations.map(&:last_status), current_user&.account_id)
  end

  def read
    @conversation.update!(unread: false, unread_count: 0)
    render json: @conversation, serializer: REST::ConversationSerializer
  end

  def unread
    @conversation.update!(unread: true, unread_count: 1)
    render json: @conversation, serializer: REST::ConversationSerializer
  end

  def title
    @conversation = AccountConversation.where(account: current_account).find_by!(conversation_id: params.require(:conversation_id))
    title = params[:title].to_s.strip.presence

    if title != @conversation.conversation.title
      @conversation.conversation.update!(title: title)
      post_title_change!(title)
    end

    render json: @conversation, serializer: REST::ConversationSerializer
  end

  def destroy
    @conversation.destroy!
    render_empty
  end

  private

  def set_conversation
    @conversation = AccountConversation.where(account: current_account).find(params[:id])
  end

  def post_title_change!(title)
    recipients = @conversation.participant_accounts
    mentions = recipients.map { |account| "@#{account.acct}" }.join(' ')
    actor = (current_account.display_name.presence || current_account.username).tr('@', '＠')
    message = title ? "#{actor}님의 변경. '#{title.tr('@', '＠')}'" : "#{actor}님이 단체방 이름을 삭제하였습니다."

    PostStatusService.new.call(
      current_account,
      text: "#{mentions} #{message}",
      thread: @conversation.last_status,
      spoiler_text: "#{Status::CONVERSATION_TITLE_CHANGE_PREFIX}#{message}",
      visibility: :direct,
      allowed_mentions: recipients.map(&:id)
    )
  end

  def paginated_conversations
    AccountConversation.where(account: current_account)
      .includes(
        :conversation,
        account: [:account_stat, user: :role],
        last_status: [
          :media_attachments,
          :status_stat,
          :tags,
          {
            preview_cards_status: { preview_card: { author_account: [:account_stat, user: :role] } },
            active_mentions: :account,
            account: [:account_stat, user: :role],
          },
        ]
      )
      .to_a_paginated_by_id(limit_param(LIMIT), params_slice(:max_id, :since_id, :min_id))
  end

  def next_path
    api_v1_conversations_url pagination_params(max_id: pagination_max_id) if records_continue?
  end

  def prev_path
    api_v1_conversations_url pagination_params(min_id: pagination_since_id) unless @conversations.empty?
  end

  def pagination_max_id
    @conversations.last.last_status_id
  end

  def pagination_since_id
    @conversations.first.last_status_id
  end

  def records_continue?
    @conversations.size == limit_param(LIMIT)
  end
end
