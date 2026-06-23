# frozen_string_literal: true

class BrandingAssetsController < ActionController::Base # rubocop:disable Rails/ApplicationController
  def background
    upload = SiteUpload.find_by(var: 'background')

    if upload&.file&.exists?
      expires_now
      redirect_to upload.file.url('2560'), allow_other_host: false
    else
      head :no_content
    end
  end
end
