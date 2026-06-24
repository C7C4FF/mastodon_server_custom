# frozen_string_literal: true

module CustomBrandingTheme
  OPACITY_SETTING = :branding_timeline_panel_opacity
  BEGIN_MARKER = '/* C7C4FF branding theme:start */'
  END_MARKER = '/* C7C4FF branding theme:end */'

  COLOR_SETTINGS = {
    branding_color_base: {
      default: '#1f883d',
      css_vars: %w(--color-base --color-bg-brand-base --color-text-brand --color-border-brand --color-accent-dark --color-brand-mastodon),
    },
    branding_color_base_hover: {
      default: '#2da44e',
      css_vars: %w(--color-bg-brand-base-hover --color-accent --color-brand-mastodon-links --color-link --color-hashtag --color-mention),
    },
    branding_color_base_soft: {
      default: '#dff7e7',
      css_vars: %w(--color-bg-brand-soft --color-bg-brand-softest --color-border-brand-soft),
    },
    branding_color_text_primary: {
      default: '#f7f9f9',
      css_vars: %w(--color-text-primary --color-fg),
    },
    branding_color_text_secondary: {
      default: '#8493a7',
      css_vars: %w(--color-text-secondary --color-brand-mastodon-text-light),
    },
    branding_color_text_tertiary: {
      default: '#717c9b',
      css_vars: %w(--color-text-tertiary),
    },
    branding_color_dim: {
      default: '#717c9b',
      css_vars: %w(--color-dim --color-brand-mastodon-dim),
    },
    branding_color_light_text: {
      default: '#f7f9f9',
      css_vars: %w(--color-light-text --color-button-text --color-ghost-button-text),
    },
  }.freeze

  COLOR_SCHEMES = {
    dark: {
      title: '어두움 모드',
      suffix: nil,
      selector: 'body, body.layout-single-column, body.layout-multiple-columns, body.app-body, .ui',
    },
    light: {
      title: '밝음 모드',
      suffix: '_light',
      selector: "html[data-color-scheme='light'] body, html[data-color-scheme='light'] body.layout-single-column, html[data-color-scheme='light'] body.layout-multiple-columns, html[data-color-scheme='light'] body.app-body, html[data-color-scheme='light'] .ui",
    },
  }.freeze

  DEFAULTS = COLOR_SETTINGS.transform_values { |config| config[:default] }.merge(
    branding_color_base_light: '#1f883d',
    branding_color_base_hover_light: '#2da44e',
    branding_color_base_soft_light: '#eaf8ef',
    branding_color_text_primary_light: '#1f1b23',
    branding_color_text_secondary_light: '#5f576d',
    branding_color_text_tertiary_light: '#81778f',
    branding_color_dim_light: '#9388a6',
    branding_color_light_text_light: '#1f1b23',
    OPACITY_SETTING => 80
  ).freeze

  FORM_COLOR_GROUPS = [
    {
      title: 'color-base',
      fields: {
        branding_color_base: {
          label: '강조 색깔',
          hint: '주요 버튼, 링크, 선택 상태, brand/accent 계열에 함께 적용됩니다.',
        },
        branding_color_base_hover: {
          label: 'hover 색깔',
          hint: 'hover, 링크, 해시태그, 멘션 등 보조 강조 계열에 적용됩니다.',
        },
        branding_color_base_soft: {
          label: 'soft 색깔',
          hint: '연한 강조 배경과 연한 강조 테두리에 적용됩니다.',
        },
      },
    },
    {
      title: '글자 색',
      fields: {
        branding_color_text_primary: {
          label: '기본 글자 색',
          hint: '본문과 제목의 primary 텍스트 색입니다.',
        },
        branding_color_text_secondary: {
          label: '보조 글자 색',
          hint: '힌트, 메타 정보, 보조 링크 텍스트 색입니다.',
        },
        branding_color_text_tertiary: {
          label: '흐린 글자 색',
          hint: '가장 낮은 우선순위의 tertiary 텍스트 색입니다.',
        },
      },
    },
    {
      title: '보조 텍스트 색',
      fields: {
        branding_color_dim: {
          label: '--color-dim',
          hint: '흐리게 표시되는 텍스트와 아이콘 계열 색입니다.',
        },
        branding_color_light_text: {
          label: '--color-light-text',
          hint: '밝은 텍스트와 버튼 텍스트 색입니다.',
        },
      },
    },
  ].freeze

  module_function

  def setting_keys
    [OPACITY_SETTING, *color_setting_keys]
  end

  def color_setting_keys
    COLOR_SCHEMES.flat_map do |_, scheme|
      COLOR_SETTINGS.keys.map { |key| scheme_key(key, scheme) }
    end
  end

  def scheme_key(key, scheme)
    :"#{key}#{scheme[:suffix]}"
  end

  def valid_hex?(value)
    value.to_s.match?(/\A#[0-9a-fA-F]{6}\z/)
  end

  def normalize_hex(value, fallback)
    value = value.to_s.strip
    value = "##{value}" if value.match?(/\A[0-9a-fA-F]{6}\z/)
    valid_hex?(value) ? value.downcase : fallback
  end

  def normalize_opacity(value)
    Integer(value).clamp(0, 100)
  rescue ArgumentError, TypeError
    DEFAULTS[OPACITY_SETTING]
  end

  def values_from_settings
    setting_keys.index_with do |key|
      value = Setting.public_send(key)
      value.presence || DEFAULTS[key]
    end
  end

  def css
    css_for(values_from_settings)
  end

  def css_block
    [BEGIN_MARKER, css, END_MARKER].join("\n")
  end

  def replace_block(custom_css)
    custom_css.to_s
              .gsub(/\n*#{Regexp.escape(BEGIN_MARKER)}.*?#{Regexp.escape(END_MARKER)}\n*/m, "\n")
              .strip
  end

  def reset_settings!
    setting_keys.each do |key|
      setting = Setting.where(var: key).first_or_initialize(var: key)
      setting.update!(value: DEFAULTS[key])
    end

    Setting.custom_css = replace_block(Setting.custom_css)
    Rails.cache.delete(:setting_digest_custom_css)
  end

  def css_for(values)
    opacity = normalize_opacity(values[OPACITY_SETTING])

    lines = []
    COLOR_SCHEMES.each_value do |scheme|
      lines << "#{scheme[:selector]} {"
      COLOR_SETTINGS.each do |key, config|
        setting_key = scheme_key(key, scheme)
        color = normalize_hex(values[setting_key], DEFAULTS[setting_key] || config[:default])
        config[:css_vars].each { |css_var| lines << "  #{css_var}: #{color};" }
      end
      lines << "  --custom-timeline-panel-opacity: #{opacity}%;"
      lines << '}'
      lines << ''
    end

    lines << 'body.has-custom-public-background {'
    lines << "  --custom-timeline-panel-opacity: #{opacity}%;"
    lines << '}'
    lines << ''
    lines << icon_color_css

    lines.join("\n")
  end

  def icon_color_css
    <<~CSS.strip
      body.layout-single-column .column-link .icon,
      body.layout-multiple-columns .column-link .icon,
      body.layout-single-column .ui__navigation-bar__item .icon,
      body.layout-multiple-columns .ui__navigation-bar__item .icon,
      body.layout-single-column .icon-with-badge .icon,
      body.layout-multiple-columns .icon-with-badge .icon {
        background-image: none !important;
        color: var(--color-light-text);
      }

      body.layout-single-column .column-link.active .icon,
      body.layout-multiple-columns .column-link.active .icon,
      body.layout-single-column .ui__navigation-bar__item.active .icon,
      body.layout-multiple-columns .ui__navigation-bar__item.active .icon,
      body.layout-single-column .active .icon-with-badge .icon,
      body.layout-multiple-columns .active .icon-with-badge .icon {
        color: var(--color-text-brand);
      }

      body.layout-single-column .column-link .icon path,
      body.layout-multiple-columns .column-link .icon path,
      body.layout-single-column .ui__navigation-bar__item .icon path,
      body.layout-multiple-columns .ui__navigation-bar__item .icon path,
      body.layout-single-column .icon-with-badge .icon path,
      body.layout-multiple-columns .icon-with-badge .icon path {
        display: block !important;
        fill: currentColor;
        stroke: currentColor;
      }
    CSS
  end
end
