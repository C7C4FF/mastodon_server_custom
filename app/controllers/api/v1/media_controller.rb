# frozen_string_literal: true

class Api::V1::MediaController < Api::BaseController
  include AccountSwitcherConcern

  before_action -> { doorkeeper_authorize! :write, :'write:media' }
  before_action :require_user!
  before_action :set_media_account
  before_action :set_media_attachment, except: [:create, :destroy]
  before_action :check_processing, except: [:create, :destroy]

  def show
    render json: @media_attachment, serializer: REST::MediaAttachmentSerializer, status: status_code_for_media_attachment
  end

  def create
    @media_attachment = current_account.media_attachments.create!(media_attachment_params)
    render json: @media_attachment, serializer: REST::MediaAttachmentSerializer
  rescue Paperclip::Errors::NotIdentifiedByImageMagickError
    render json: file_type_error, status: 422
  rescue Paperclip::Error => e
    Rails.logger.error "#{e.class}: #{e.message}"
    render json: processing_error, status: 500
  end

  def update
    @media_attachment.update!(updateable_media_attachment_params)
    render json: @media_attachment, serializer: REST::MediaAttachmentSerializer, status: status_code_for_media_attachment
  end

  def destroy
    @media_attachment = current_account.media_attachments.find(params[:id])

    return render json: in_usage_error, status: 422 unless @media_attachment.status_id.nil?

    @media_attachment.destroy
    render_empty
  end

  private

  def current_account
    @media_account || super
  end

  def set_media_account
    @media_account = current_user.account

    return if params[:account_id].blank?
    return if params[:account_id].to_s == current_user.account_id.to_s

    target_user = switchable_account_user_for_account_id(params[:account_id])

    return render json: { error: 'Account is not available for switching' }, status: 404 unless target_user
    return render json: { error: 'Your login is currently disabled' }, status: 403 unless target_user.functional?

    @media_account = target_user.account
  end

  def status_code_for_media_attachment
    @media_attachment.not_processed? ? 206 : 200
  end

  def set_media_attachment
    @media_attachment = current_account.media_attachments.where(status_id: nil).find(params[:id])
  end

  def check_processing
    render json: processing_error, status: 422 if @media_attachment.processing_failed?
  end

  def media_attachment_params
    params.permit(:file, :thumbnail, :description, :focus)
  end

  def updateable_media_attachment_params
    params.permit(:thumbnail, :description, :focus)
  end

  def file_type_error
    { error: 'File type of uploaded media could not be verified' }
  end

  def processing_error
    { error: 'Error processing thumbnail for uploaded media' }
  end

  def in_usage_error
    { error: 'Media attachment is currently used by a status' }
  end
end
