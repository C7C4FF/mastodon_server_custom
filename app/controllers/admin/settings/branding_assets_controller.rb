# frozen_string_literal: true

class Admin::Settings::BrandingAssetsController < Admin::SettingsController
  def update
    authorize :settings, :update?

    if params[:branding_assets_action] == 'reset_theme'
      reset_branding_theme_settings
      redirect_to after_update_redirect_path, notice: t('generic.changes_saved_msg')
      return
    end

    @admin_settings = Form::AdminSettings.new(settings_params)

    if @admin_settings.save
      redirect_to after_update_redirect_path, notice: t('generic.changes_saved_msg')
    else
      render :show
    end
  end

  private

  def after_update_redirect_path
    admin_settings_branding_assets_path
  end

  def reset_branding_theme_settings
    CustomBrandingTheme.reset_settings!
  end
end
