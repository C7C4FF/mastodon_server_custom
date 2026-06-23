# frozen_string_literal: true

module BrandingHelper
  def custom_logo_path(size = 'display', variant = nil)
    custom_logo_upload(variant)&.file&.url(size) || frontend_asset_path('images/c7c4ff_logo_icon.png')
  end

  def public_background_stylesheet
    background_light = custom_background_url(:light)
    background_dark = custom_background_url(:dark)
    return if background_light.blank? && background_dark.blank?

    content_tag(:style, <<~CSS.squish.html_safe, nonce: request.content_security_policy_nonce)
      html,
      body,
      body.app-body,
      body.has-public-background,
      body.has-custom-public-background,
      body.layout-multiple-columns,
      body.layout-single-column {
        --custom-public-background-image-light: #{css_url(background_light)};
        --custom-public-background-image-dark: #{css_url(background_dark)};
        --custom-public-background-image: var(--custom-public-background-image-dark);
      }

      html[data-color-scheme='light'],
      html[data-color-scheme='light'] body,
      body.theme-mastodon-light {
        --custom-public-background-image: var(--custom-public-background-image-light);
      }

      html[data-color-scheme='dark'],
      html[data-color-scheme='dark'] body {
        --custom-public-background-image: var(--custom-public-background-image-dark);
      }

      .custom-public-background {
        position: fixed;
        inset: 0;
        z-index: 0;
        pointer-events: none;
        background-image: linear-gradient(rgba(5, 7, 8, 0.08), rgba(5, 7, 8, 0.08)), var(--custom-public-background-image) !important;
        background-size: cover;
        background-position: center;
        background-attachment: fixed;
      }

      body.app-body .app-holder,
      body.layout-multiple-columns .app-holder,
      body.layout-single-column .app-holder {
        position: relative;
        z-index: 1;
        background: transparent !important;
      }
    CSS
  end

  def custom_branding_theme_stylesheet
    content_tag(:style, CustomBrandingTheme.css.html_safe, nonce: request.content_security_policy_nonce)
  end

  def public_background_layer
    return unless custom_background?

    tag.div('', class: 'custom-public-background', aria: { hidden: true })
  end

  def public_background_body_class
    'has-public-background has-custom-public-background' if custom_background?
  end

  def logo_as_symbol(version = :icon)
    case version
    when :icon
      _logo_as_symbol_icon
    when :wordmark
      _logo_as_symbol_wordmark
    end
  end

  def _logo_as_symbol_wordmark
    custom_logo_image_tag('logo logo--wordmark logo--c7c4ff')
  end

  def _logo_as_symbol_icon
    custom_logo_image_tag('logo logo--icon logo--c7c4ff')
  end

  def render_logo
    custom_logo_image_tag('logo logo--wordmark logo--c7c4ff')
  end

  private

  def custom_logo_upload(variant = nil)
    case variant
    when :light
      instance_presenter.logo_light || instance_presenter.logo
    when :dark
      instance_presenter.logo_dark || instance_presenter.logo
    else
      instance_presenter.logo
    end
  end

  def custom_background_url(variant = nil)
    upload = case variant
             when :light
               instance_presenter.background_light || instance_presenter.background || instance_presenter.background_dark
             when :dark
               instance_presenter.background_dark || instance_presenter.background || instance_presenter.background_light
             else
               instance_presenter.background || instance_presenter.background_dark || instance_presenter.background_light
             end

    upload&.file&.url('2560')
  end

  def custom_background?
    custom_background_url.present?
  end

  def css_url(url)
    escaped_url = url.to_s.gsub('\\', '\\\\\\').gsub('"', '\"')
    "url(\"#{escaped_url}\")"
  end

  def custom_logo_image_tag(css_class)
    image_tag(
      custom_logo_path,
      alt: 'C7C4FF',
      class: class_names(css_class, 'logo--themeable'),
      data: {
        logo_light: custom_logo_path('display', :light),
        logo_dark: custom_logo_path('display', :dark),
      }
    )
  end
end
