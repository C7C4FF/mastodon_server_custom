# frozen_string_literal: true

class Api::V1::Admin::ThemesController < Api::BaseController
  include Authorization

  before_action -> { doorkeeper_authorize! :write }
  before_action :require_user!
  after_action :verify_authorized

  def update
    authorize :dashboard, :index?
    Setting.force_dark_theme = !Setting.force_dark_theme
    ThemeReloadWorker.perform_async
    render_empty
  end
end
