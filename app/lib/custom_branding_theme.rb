# frozen_string_literal: true

module CustomBrandingTheme
  OPACITY_SETTING = :branding_timeline_panel_opacity
  BEGIN_MARKER = '/* C7C4FF branding theme:start */'
  END_MARKER = '/* C7C4FF branding theme:end */'

  COLOR_SETTINGS = {
    branding_color_base: {
      default: '#1f883d',
      css_vars: %w(--color-base --color-bg-brand-base --color-text-brand --color-border-brand --color-accent-dark --color-brand-mastodon --color-text-bookmark-highlight),
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
    branding_color_text_on_brand_base: {
      default: '#f7f9f9',
      css_vars: %w(--color-text-on-brand-base),
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
    branding_color_text_on_brand_base_light: '#f7f9f9',
    OPACITY_SETTING => 80
  ).freeze

  NAVIGATION_ICONS = {
    'icon-home' => {
      view_box: '0 0 512 512',
      default: {
        inner_html: '<path d="M80 212v236a16 16 0 0016 16h96V328a24 24 0 0124-24h80a24 24 0 0124 24v136h96a16 16 0 0016-16V212" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="38"></path><path d="M480 256L266.89 52c-5-5.28-16.69-5.34-21.78 0L32 256M400 179V64h-48v69" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="38"></path>',
      },
      active: {
        inner_html: '<path d="M261.56 101.28a8 8 0 00-11.06 0L66.4 277.15a8 8 0 00-2.47 5.79L63.9 448a32 32 0 0032 32H192a16 16 0 0016-16V328a8 8 0 018-8h80a8 8 0 018 8v136a16 16 0 0016 16h96.06a32 32 0 0032-32V282.94a8 8 0 00-2.47-5.79z" fill="currentColor"></path><path d="M490.91 244.15l-74.8-71.56V64a16 16 0 00-16-16h-48a16 16 0 00-16 16v32l-57.92-55.38C272.77 35.14 264.71 32 256 32c-8.68 0-16.72 3.14-22.14 8.63l-212.7 203.5c-6.22 6-7 15.87-1.34 22.37A16 16 0 0043 267.56L250.5 69.28a8 8 0 0111.06 0l207.52 198.28a16 16 0 0022.59-.44c6.14-6.36 5.63-16.86-.76-22.97z" fill="currentColor"></path>',
      },
    },

    'icon-globe' => {
      view_box: '0 0 512 512',
      default: {
        inner_html: '<path fill="currentColor" d="M 512.00 383.82 L 512.00 385.55 C 509.71 419.39 473.05 422.09 447.81 418.87 Q 423.66 415.79 400.31 408.70 Q 358.58 396.03 318.76 378.21 Q 218.90 333.52 129.46 270.53 C 92.32 244.38 56.82 216.22 27.43 182.58 C 14.63 167.94 1.88 149.41 0.00 128.96 L 0.00 125.94 C 3.19 91.33 40.56 90.05 66.57 93.40 Q 81.64 95.34 88.25 97.23 C 99.02 100.32 103.61 112.14 97.29 121.55 C 92.20 129.11 85.23 129.19 76.43 127.41 C 64.10 124.92 44.84 121.70 32.89 126.36 A 1.55 1.54 74.3 0 0 31.93 128.08 C 34.07 139.90 43.53 152.31 51.28 161.22 Q 68.49 181.02 88.94 198.55 Q 89.49 199.02 89.73 198.34 Q 110.62 140.43 161.78 107.51 C 234.44 60.76 331.69 75.26 388.09 139.91 C 446.04 206.35 446.71 303.97 388.97 370.93 Q 388.58 371.38 389.14 371.58 Q 413.92 380.31 439.48 385.26 C 451.88 387.65 467.05 389.92 479.11 385.65 A 1.51 1.50 -14.2 0 0 480.10 384.00 C 477.90 369.69 463.57 354.46 454.60 343.62 C 440.99 327.16 463.05 306.29 479.15 323.40 C 495.03 340.29 510.01 360.98 512.00 383.82 Z M 115.39 210.46 Q 136.86 228.57 159.38 244.15 C 223.66 288.63 294.05 327.49 367.32 354.98 A 1.46 1.44 30.8 0 0 368.93 354.58 Q 400.10 318.66 405.76 270.75 Q 407.08 259.64 406.38 249.56 C 401.05 172.60 342.31 113.52 265.72 106.81 Q 255.74 105.94 245.77 106.92 C 185.42 112.87 134.96 151.32 114.89 208.65 Q 114.52 209.72 115.39 210.46 Z M 295.33 328.94 A 0.34 0.34 0.0 0 0 295.16 329.58 L 299.51 331.72 A 0.34 0.34 0.0 0 0 300.00 331.41 L 300.00 329.51 A 0.34 0.34 0.0 0 0 299.68 329.17 L 295.33 328.94 Z"></path><path fill="currentColor" d="M 307.69 408.30 C 316.86 412.38 316.05 421.82 306.19 424.66 C 209.45 452.48 109.79 396.22 85.13 298.09 Q 83.95 293.40 84.37 291.18 C 85.73 284.03 93.55 284.22 98.50 287.80 Q 197.11 359.12 307.69 408.30 Z M 263.31 410.94 Q 262.74 410.51 262.12 410.23 Q 199.27 381.56 142.55 342.19 Q 129.49 333.13 117.25 323.09 A 0.18 0.18 0.0 0 0 116.97 323.31 C 142.74 377.01 195.57 410.10 255.44 411.80 Q 261.32 411.97 263.93 411.40 Q 264.37 411.30 264.00 411.06 Q 263.69 410.85 263.31 410.94 Z"></path>',
      },
      active: {
        inner_html: '<path d="M96.85 286.62a8 8 0 00-12.53 8.25C102.07 373.28 172.3 432 256 432a175.31 175.31 0 0052.41-8 8 8 0 00.79-15 1120 1120 0 01-109.48-55.61 1126.24 1126.24 0 01-102.87-66.77zM492.72 339.51c-4.19-5.58-9.11-11.44-14.7-17.53a15.83 15.83 0 00-26.56 5.13c0 .16-.11.31-.17.47a15.75 15.75 0 003.15 16.06c22.74 25 26.42 38.51 25.48 41.36-2 2.23-17.05 6.89-58.15-3.53q-8.83-2.24-19.32-5.46-6.76-2.08-13.79-4.49a176.76 176.76 0 0019.54-27.25c.17-.29.35-.58.52-.88A175.39 175.39 0 00432 256a178.87 178.87 0 00-1-19c-9.57-88.17-84.4-157-175-157a175.37 175.37 0 00-106.4 35.89 177.4 177.4 0 00-45.83 51.84c-.16.29-.34.58-.51.87a175.48 175.48 0 00-13.83 30.52q-5.59-4.87-10.79-9.67c-5.39-5-10.17-9.63-14.42-14-29.57-30.26-33.09-45.61-32.16-48.45 2-2.23 15.54-5.87 48.62 1.31A15.82 15.82 0 0096.22 123l.36-.44a15.74 15.74 0 00-8.67-25.43A237.38 237.38 0 0064.13 93c-30.72-3.53-50.83 2.52-59.78 18-3.24 5.58-6.35 15.09-2.72 28.6C7 159.66 26.14 184 53.23 209.5c8.63 8.13 18.06 16.37 28.12 24.64 7.32 6 15 12.06 22.9 18.08q7.91 6 16.15 12T137.1 276c25.41 17.61 52.26 34.52 78.59 49.69q14.34 8.26 28.64 16t28.37 14.81c21.9 11 43.35 20.92 63.86 29.43q13.19 5.48 25.81 10.16c11.89 4.42 23.37 8.31 34.31 11.59l1.1.33c25.73 7.66 47.42 11.69 64.48 12H464c21.64 0 36.3-6.38 43.58-19 9.09-15.62 4.08-36.32-14.86-61.5z" fill="currentColor"></path>',
      },
    },

    'icon-bell' => {
      view_box: '0 0 24 24',
      default: {
        inner_html: '<path d="M18 8.4c0-1.697-.632-3.325-1.757-4.525C15.117 2.675 13.59 2 12 2c-1.591 0-3.117.674-4.243 1.875C6.632 5.075 6 6.703 6 8.4 6 15.867 3 18 3 18h18s-3-2.133-3-9.6zM13.73 21a1.999 1.999 0 01-3.46 0" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></path>',
      },
      active: {
        inner_html: '<path d="M18 8.4c0-1.697-.632-3.325-1.757-4.525C15.117 2.675 13.59 2 12 2c-1.591 0-3.117.674-4.243 1.875C6.632 5.075 6 6.703 6 8.4 6 15.867 3 18 3 18h18s-3-2.133-3-9.6zM13.73 21a1.999 1.999 0 01-3.46 0" fill="currentColor" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></path>',
      },
    },

    'icon-star' => {
      view_box: '0 0 24 24',
      default: {
        inner_html: '<path fill="currentColor" d="M16.5 3C19.538 3 22 5.5 22 9c0 7-7.5 11-10 12.5C9.5 20 2 16 2 9c0-3.5 2.5-6 5.5-6C9.36 3 11 4 12 5c1-1 2.64-2 4.5-2zm-3.566 15.604a26.953 26.953 0 0 0 2.42-1.701C18.335 14.533 20 11.943 20 9c0-2.36-1.537-4-3.5-4c-1.076 0-2.24.57-3.086 1.414L12 7.828l-1.414-1.414C9.74 5.57 8.576 5 7.5 5C5.56 5 4 6.656 4 9c0 2.944 1.666 5.533 4.645 7.903c.745.592 1.54 1.145 2.421 1.7c.299.189.595.37.934.572c.339-.202.635-.383.934-.571z"></path>',
      },
      active: {
        inner_html: '<path d="M20.884 13.19c-1.351 2.48-4.001 5.12-8.379 7.67l-.503.3-.504-.3c-4.379-2.55-7.029-5.19-8.382-7.67-1.36-2.5-1.41-4.86-.514-6.67.887-1.79 2.647-2.91 4.601-3.01 1.651-.09 3.368.56 4.798 2.01 1.429-1.45 3.146-2.1 4.796-2.01 1.954.1 3.714 1.22 4.601 3.01.896 1.81.846 4.17-.514 6.67z" fill="currentColor"></path>',
      },
    },

    'icon-bookmarks' => {
      view_box: '0 0 24 24',
      default: {
        inner_html: '<path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></path>',
      },
      active: {
        inner_html: '<path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z" fill="currentColor" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></path>',
      },
    },

    'icon-mail' => {
      view_box: '0 0 24 24',
      default: {
        inner_html: '<path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></path><polyline points="22, 6 12, 13 2, 6" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></polyline>',
      },
      active: {
        inner_html: '<path d="M3 3h18c1.1 0 2 .9 2 2v14c0 1.1-.9 2-2 2H3c-1.1 0-2-.9-2-2V5c0-1.1.9-2 2-2z" fill="currentColor" stroke="none"></path><polyline points="19, 7 12, 12 5, 7" fill="none" stroke="__ICON_CUTOUT_COLOR__" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></polyline>',
      },
    },

    'icon-cog' => {
      view_box: '0 0 24 24',
      default: {
        inner_html: '<line x1="4" y1="21" x2="4" y2="14" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></line><line x1="4" y1="10" x2="4" y2="3" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></line><line x1="12" y1="21" x2="12" y2="12" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></line><line x1="12" y1="8" x2="12" y2="3" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></line><line x1="20" y1="21" x2="20" y2="16" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></line><line x1="20" y1="12" x2="20" y2="3" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></line><line x1="1" y1="14" x2="7" y2="14" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></line><line x1="9" y1="8" x2="15" y2="8" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></line><line x1="17" y1="16" x2="23" y2="16" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></line>',
      },
      active: {
        inner_html: '<line x1="4" y1="21" x2="4" y2="14" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></line><line x1="4" y1="10" x2="4" y2="3" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></line><line x1="12" y1="21" x2="12" y2="12" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></line><line x1="12" y1="8" x2="12" y2="3" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></line><line x1="20" y1="21" x2="20" y2="16" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></line><line x1="20" y1="12" x2="20" y2="3" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></line><line x1="1" y1="14" x2="7" y2="14" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></line><line x1="9" y1="8" x2="15" y2="8" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></line><line x1="17" y1="16" x2="23" y2="16" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></line>',
      },
    },

    'icon-' => {
      view_box: '0 0 24 24',
      default: {
        inner_html: '<circle cx="12" cy="12" r="1" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></circle><circle cx="19" cy="12" r="1" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></circle><circle cx="5" cy="12" r="1" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></circle>',
      },
      active: {
        inner_html: '<circle cx="12" cy="12" r="1" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></circle><circle cx="19" cy="12" r="1" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></circle><circle cx="5" cy="12" r="1" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></circle>',
      },
    },
  }.freeze

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
        branding_color_text_on_brand_base: {
          label: '--color-text-on-brand-base',
          hint: '브랜드 색 배경 위에 올라가는 텍스트 색입니다.',
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
      lines.concat(bookmark_icon_css_vars(values, scheme))
      lines.concat(status_action_icon_css_vars(values, scheme))
      lines << "  --custom-timeline-panel-opacity: #{opacity}%;"
      lines << '}'
      lines << ''
    end

    lines << 'body.has-custom-public-background {'
    lines << "  --custom-timeline-panel-opacity: #{opacity}%;"
    lines << '}'
    lines << ''
    lines << navigation_icon_css(values)
    lines << icon_button_css(values)

    lines.join("\n")
  end

  def encode_svg(svg)
    svg.to_s.gsub(/\s+/, ' ').strip.gsub(/[ #%<>"']/) do |char|
      case char
      when ' '
        '%20'
      when '#'
        '%23'
      when '%'
        '%25'
      when '<'
        '%3C'
      when '>'
        '%3E'
      when '"'
        '%22'
      when "'"
        '%27'
      end
    end
  end

  def navigation_icon_data_uri(icon, state, color, cutout_color = nil)
    icon_state = icon[state] || icon[:default]
    normalized_color = normalize_hex(color, DEFAULTS[:branding_color_light_text])
    normalized_cutout_color = normalize_hex(cutout_color || '#232543', '#232543')

    inner_html = icon_state[:inner_html].gsub('__ICON_CUTOUT_COLOR__', normalized_cutout_color)

    svg = <<~SVG
      <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="#{icon[:view_box]}" aria-hidden="true" color="#{normalized_color}" fill="none" stroke="none">
        #{inner_html}
      </svg>
    SVG

    "data:image/svg+xml,#{encode_svg(svg)}"
  end

  def bookmark_icon_data_uri(state, color)
    normalized_color = normalize_hex(color, DEFAULTS[:branding_color_base])

    path = case state
           when :filled
             '<path d="M4 4.5C4 3.12 5.119 2 6.5 2h11C18.881 2 20 3.12 20 4.5v18.44l-8-5.71-8 5.71V4.5z"></path>'
           else
             '<path d="M4 4.5C4 3.12 5.119 2 6.5 2h11C18.881 2 20 3.12 20 4.5v18.44l-8-5.71-8 5.71V4.5zM6.5 4c-.276 0-.5.22-.5.5v14.56l6-4.29 6 4.29V4.5c0-.28-.224-.5-.5-.5h-11z"></path>'
           end

    svg = <<~SVG
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="20" height="20" fill="#{normalized_color}" aria-hidden="true">
        <g>#{path}</g>
      </svg>
    SVG

    "data:image/svg+xml,#{encode_svg(svg)}"
  end

  def bookmark_icon_css_vars(values, scheme)
    base_color = normalize_hex(values[scheme_key(:branding_color_base, scheme)], DEFAULTS[scheme_key(:branding_color_base, scheme)])
    dim_color = normalize_hex(values[scheme_key(:branding_color_dim, scheme)], DEFAULTS[scheme_key(:branding_color_dim, scheme)])

    default_icon = bookmark_icon_data_uri(:outline, dim_color)
    highlight_icon = bookmark_icon_data_uri(:outline, base_color)
    active_icon = bookmark_icon_data_uri(:filled, base_color)

    [
      "  --icon-bookmark: url(\"#{default_icon}\");",
      "  --icon-bookmark-status-hover: url(\"#{highlight_icon}\");",
      "  --icon-bookmark-status-hover-red: url(\"#{highlight_icon}\");",
      "  --icon-bookmark-active: url(\"#{active_icon}\");",
      "  --icon-bookmark-detailed-status-action-bar: url(\"#{default_icon}\");",
      "  --icon-bookmark-detailed-status-action-bar-hover: url(\"#{highlight_icon}\");",
      "  --icon-bookmark-detailed-status-action-bar-active: url(\"#{active_icon}\");",
    ]
  end

  def action_icon_data_uri(name, color)
    normalized_color = normalize_hex(color, DEFAULTS[:branding_color_base])

    svg = case name
          when :reply
            <<~SVG
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="18" height="18" fill="#{normalized_color}" aria-hidden="true">
                <g><path d="M1.751 10c0-4.42 3.584-8 8.005-8h4.366c4.49 0 8.129 3.64 8.129 8.13 0 2.96-1.607 5.68-4.196 7.11l-8.054 4.46v-3.69h-.067c-4.49.1-8.183-3.51-8.183-8.01zm8.005-6c-3.317 0-6.005 2.69-6.005 6 0 3.37 2.77 6.08 6.138 6.01l.351-.01h1.761v2.3l5.087-2.81c1.951-1.08 3.163-3.13 3.163-5.36 0-3.39-2.744-6.13-6.129-6.13H9.756z"></path></g>
              </svg>
            SVG
          when :boost
            <<~SVG
              <svg version="1.0" xmlns="http://www.w3.org/2000/svg" width="21" height="21" viewBox="0 0 136 136">
                <path fill="#{normalized_color}" d="M51 23.8c0 .4 2.4 3.1 5.3 6l5.3 5.2h34.6l3.4 3.4 3.4 3.4v47.4l-6.7-6.1-6.8-6.1-4 4-4 4 13.8 13.7 13.7 13.8L122.5 99c7.4-7.4 13.5-13.7 13.5-14-.1-.3-1.7-2.3-3.6-4.4l-3.5-4-6.8 6.8-6.9 6.9-.4-25.4c-.3-23.8-.4-25.7-2.5-29.4-2.7-5.1-5.7-7.9-11.3-10.4-4.1-1.9-6.5-2.1-27.2-2.1-12.6 0-22.8.4-22.8.8zM13 37.5-.4 51l3.8 3.9 3.9 4 6.6-6.1 6.6-6 .5 24.4c.5 26.3.7 27.2 6.6 33.2 6 5.9 6.8 6.1 33.2 6.4 13.3.2 24.2-.1 24.2-.5 0-.5-2.2-3-4.8-5.6l-4.8-4.7-15.9-.1c-17.7 0-21.7-.9-24.9-5.2-2-2.7-2.1-4.2-2.3-26.5l-.2-23.6 6.7 6.7C42.5 55 46 58 46.6 58c.5 0 2.5-1.6 4.4-3.5l3.4-3.5L41 37.5C33.6 30.1 27.3 24 27 24c-.3 0-6.6 6.1-14 13.5z"></path>
              </svg>
            SVG
          when :heart_filled
            <<~SVG
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="20" height="20" aria-hidden="true" fill="#{normalized_color}">
                <g><path d="M20.884 13.19c-1.351 2.48-4.001 5.12-8.379 7.67l-.503.3-.504-.3c-4.379-2.55-7.029-5.19-8.382-7.67-1.36-2.5-1.41-4.86-.514-6.67.887-1.79 2.647-2.91 4.601-3.01 1.651-.09 3.368.56 4.798 2.01 1.429-1.45 3.146-2.1 4.796-2.01 1.954.1 3.714 1.22 4.601 3.01.896 1.81.846 4.17-.514 6.67z"></path></g>
              </svg>
            SVG
          else
            <<~SVG
              <svg viewBox="0 0 24 24" color="inherit" width="20" height="20" xmlns="http://www.w3.org/2000/svg">
                <path fill="#{normalized_color}" d="M16.5 3C19.538 3 22 5.5 22 9c0 7-7.5 11-10 12.5C9.5 20 2 16 2 9c0-3.5 2.5-6 5.5-6C9.36 3 11 4 12 5c1-1 2.64-2 4.5-2zm-3.566 15.604a26.953 26.953 0 0 0 2.42-1.701C18.335 14.533 20 11.943 20 9c0-2.36-1.537-4-3.5-4c-1.076 0-2.24.57-3.086 1.414L12 7.828l-1.414-1.414C9.74 5.57 8.576 5 7.5 5C5.56 5 4 6.656 4 9c0 2.944 1.666 5.533 4.645 7.903c.745.592 1.54 1.145 2.421 1.7c.299.189.595.37.934.572c.339-.202.635-.383.934-.571z"></path>
              </svg>
            SVG
          end

    "data:image/svg+xml,#{encode_svg(svg)}"
  end

  def status_action_icon_css_vars(values, scheme)
    base_color = normalize_hex(values[scheme_key(:branding_color_base, scheme)], DEFAULTS[scheme_key(:branding_color_base, scheme)])
    dim_color = normalize_hex(values[scheme_key(:branding_color_dim, scheme)], DEFAULTS[scheme_key(:branding_color_dim, scheme)])

    reply_default = action_icon_data_uri(:reply, dim_color)
    reply_highlight = action_icon_data_uri(:reply, base_color)
    boost_default = action_icon_data_uri(:boost, dim_color)
    boost_active = action_icon_data_uri(:boost, base_color)
    heart_default = action_icon_data_uri(:heart_outline, dim_color)
    heart_highlight = action_icon_data_uri(:heart_outline, base_color)
    heart_active = action_icon_data_uri(:heart_filled, base_color)

    [
      "  --icon-reply: url(\"#{reply_default}\");",
      "  --icon-reply-detailed-status-action-bar: url(\"#{reply_default}\");",
      "  --icon-reply-detailed-status-action-bar-hover: url(\"#{reply_highlight}\");",
      "  --icon-reply-conversation: url(\"#{reply_highlight}\");",
      "  --icon-reply-status-hover: url(\"#{reply_highlight}\");",
      "  --icon-boost: url(\"#{boost_default}\");",
      "  --icon-boost-status: url(\"#{boost_default}\");",
      "  --icon-boost-active: url(\"#{boost_active}\");",
      "  --icon-boost-notification-filter-bar: url(\"#{boost_default}\");",
      "  --icon-boost-notification-wrapper: url(\"#{boost_active}\");",
      "  --icon-heart: url(\"#{heart_default}\");",
      "  --icon-heart-hover: url(\"#{heart_highlight}\");",
      "  --icon-heart-active: url(\"#{heart_active}\");",
      "  --icon-heart-active-red: url(\"#{heart_active}\");",
      "  --icon-heart-notification: url(\"#{heart_active}\");",
    ]
  end

  def icon_button_css(values)
    lines = []

    COLOR_SCHEMES.each_value do |scheme|
      color = normalize_hex(values[scheme_key(:branding_color_base, scheme)], DEFAULTS[scheme_key(:branding_color_base, scheme)])

      lines << "#{icon_button_selector(light: !scheme[:suffix].nil?)} {"
      lines << "  color: #{color} !important;"
      lines << '}'
      lines << ''
    end

    lines.join("\n")
  end

  def icon_button_selector(light: false)
    prefix = light ? "html[data-color-scheme='light'] " : ''

    [
      "#{prefix}body.layout-multiple-columns .icon-button .icon-button__icon",
      "#{prefix}body.layout-multiple-columns .icon-button .icon-button__icon > .icon",
      "#{prefix}body.layout-multiple-columns .icon-button > .icon",
      "#{prefix}body.layout-single-column .icon-button .icon-button__icon",
      "#{prefix}body.layout-single-column .icon-button .icon-button__icon > .icon",
      "#{prefix}body.layout-single-column .icon-button > .icon",
      "#{prefix}body .compose-form__buttons .icon-button .icon-button__icon",
      "#{prefix}body .compose-form__buttons .icon-button .icon-button__icon > .icon",
    ].join(",\n")
  end

  def navigation_scopes(light: false)
    prefix = light ? "html[data-color-scheme='light'] " : ''

    [
      "#{prefix}body .navigation-panel",
      "#{prefix}body nav.navigation-panel",
      "#{prefix}body .ui__navigation-bar",
    ].uniq
  end

  def direct_link_selector(icon_class, light: false)
    navigation_scopes(light: light).map do |scope|
      "#{scope} .column-link:has(> svg.icon.#{icon_class})"
    end.join(",\n")
  end

  def direct_svg_selector(icon_class, light: false)
    navigation_scopes(light: light).map do |scope|
      "#{scope} .column-link > svg.icon.#{icon_class}"
    end.join(",\n")
  end

  def active_direct_link_selector(icon_class, light: false)
    navigation_scopes(light: light).flat_map do |scope|
      base = "#{scope} .column-link:has(> svg.icon.#{icon_class})"

      [
        "#{base}.active",
        "#{base}.selected",
        "#{base}.column-link--active",
        "#{base}[aria-current='page']",
        "#{base}[aria-selected='true']",
      ]
    end.join(",\n")
  end

  def badge_selector(icon_class, light: false)
    navigation_scopes(light: light).map do |scope|
      "#{scope} .column-link .icon-with-badge:has(svg.icon.#{icon_class})"
    end.join(",\n")
  end

  def badge_svg_selector(icon_class, light: false)
    navigation_scopes(light: light).map do |scope|
      "#{scope} .column-link .icon-with-badge svg.icon.#{icon_class}"
    end.join(",\n")
  end

  def active_badge_selector(icon_class, light: false)
    navigation_scopes(light: light).flat_map do |scope|
      [
        "#{scope} .column-link.active .icon-with-badge:has(svg.icon.#{icon_class})",
        "#{scope} .column-link.selected .icon-with-badge:has(svg.icon.#{icon_class})",
        "#{scope} .column-link.column-link--active .icon-with-badge:has(svg.icon.#{icon_class})",
        "#{scope} .column-link[aria-current='page'] .icon-with-badge:has(svg.icon.#{icon_class})",
        "#{scope} .column-link[aria-selected='true'] .icon-with-badge:has(svg.icon.#{icon_class})",
      ]
    end.join(",\n")
  end

  def navigation_icon_css(values)
    dark_icon_color = values[:branding_color_light_text] || DEFAULTS[:branding_color_light_text]
    light_icon_color = values[:branding_color_light_text_light] || DEFAULTS[:branding_color_light_text_light]

    dark_cutout_color = '#232543'
    light_cutout_color = '#ffffff'

    lines = []

    NAVIGATION_ICONS.each do |icon_class, icon|
      dark_default_icon = navigation_icon_data_uri(icon, :default, dark_icon_color, dark_cutout_color)
      dark_active_icon = navigation_icon_data_uri(icon, :active, dark_icon_color, dark_cutout_color)

      light_default_icon = navigation_icon_data_uri(icon, :default, light_icon_color, light_cutout_color)
      light_active_icon = navigation_icon_data_uri(icon, :active, light_icon_color, light_cutout_color)

      lines << "#{direct_link_selector(icon_class)} {"
      lines << "  background-image: url(\"#{dark_default_icon}\") !important;"
      lines << '  background-repeat: no-repeat !important;'
      lines << '  background-origin: content-box !important;'
      lines << '  background-position: left center !important;'
      lines << '  background-size: 22px 22px !important;'
      lines << '}'
      lines << ''

      lines << "#{active_direct_link_selector(icon_class)} {"
      lines << "  background-image: url(\"#{dark_active_icon}\") !important;"
      lines << '  background-origin: content-box !important;'
      lines << '  background-position: left center !important;'
      lines << '  background-size: 22px 22px !important;'
      lines << '}'
      lines << ''

      lines << "#{direct_svg_selector(icon_class)} {"
      lines << '  opacity: 0 !important;'
      lines << '  width: 22px !important;'
      lines << '  height: 22px !important;'
      lines << '  min-width: 22px !important;'
      lines << '  flex: 0 0 22px !important;'
      lines << '  pointer-events: none !important;'
      lines << '}'
      lines << ''

      lines << "#{badge_selector(icon_class)} {"
      lines << "  background-image: url(\"#{dark_default_icon}\") !important;"
      lines << '  background-repeat: no-repeat !important;'
      lines << '  background-position: center center !important;'
      lines << '  background-size: 22px 22px !important;'
      lines << '  width: 22px !important;'
      lines << '  height: 22px !important;'
      lines << '  min-width: 22px !important;'
      lines << '  flex: 0 0 22px !important;'
      lines << '}'
      lines << ''

      lines << "#{active_badge_selector(icon_class)} {"
      lines << "  background-image: url(\"#{dark_active_icon}\") !important;"
      lines << '  background-position: center center !important;'
      lines << '  background-size: 22px 22px !important;'
      lines << '}'
      lines << ''

      lines << "#{badge_svg_selector(icon_class)} {"
      lines << '  opacity: 0 !important;'
      lines << '  width: 22px !important;'
      lines << '  height: 22px !important;'
      lines << '  pointer-events: none !important;'
      lines << '}'
      lines << ''

      lines << "#{direct_link_selector(icon_class, light: true)} {"
      lines << "  background-image: url(\"#{light_default_icon}\") !important;"
      lines << '  background-origin: content-box !important;'
      lines << '  background-position: left center !important;'
      lines << '  background-size: 22px 22px !important;'
      lines << '}'
      lines << ''

      lines << "#{active_direct_link_selector(icon_class, light: true)} {"
      lines << "  background-image: url(\"#{light_active_icon}\") !important;"
      lines << '  background-origin: content-box !important;'
      lines << '  background-position: left center !important;'
      lines << '  background-size: 22px 22px !important;'
      lines << '}'
      lines << ''

      lines << "#{badge_selector(icon_class, light: true)} {"
      lines << "  background-image: url(\"#{light_default_icon}\") !important;"
      lines << '  background-position: center center !important;'
      lines << '  background-size: 22px 22px !important;'
      lines << '}'
      lines << ''

      lines << "#{active_badge_selector(icon_class, light: true)} {"
      lines << "  background-image: url(\"#{light_active_icon}\") !important;"
      lines << '  background-position: center center !important;'
      lines << '  background-size: 22px 22px !important;'
      lines << '}'
      lines << ''
    end

    lines << <<~CSS
      body .navigation-panel .column-link::before {
        content: none !important;
        display: none !important;
        background-image: none !important;
      }

      body .navigation-panel .column-link {
        background-origin: content-box !important;
      }

      body .navigation-panel .column-link > svg.icon {
        width: 22px !important;
        height: 22px !important;
        min-width: 22px !important;
        flex: 0 0 22px !important;
      }

      body .navigation-panel .column-link .icon-with-badge {
        width: 22px !important;
        height: 22px !important;
        min-width: 22px !important;
        flex: 0 0 22px !important;
        background-repeat: no-repeat !important;
        background-position: center center !important;
        background-size: 22px 22px !important;
      }

      body .navigation-panel .column-link .icon-with-badge svg.icon {
        width: 22px !important;
        height: 22px !important;
      }
    CSS

    lines.join("\n")
  end
end
