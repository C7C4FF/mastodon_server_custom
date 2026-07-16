# frozen_string_literal: true

class MarkdownStatusFormatter
  include ERB::Util
  include RoutingHelper

  HEX_COLOR_RE = /#[0-9a-fA-F]{3}(?:[0-9a-fA-F]{3})?/
  TOKEN_PREFIX = 'MASTODON_MARKDOWN_TOKEN_'

  CUSTOM_TAGS = [
    {
      pattern: /\*\*\*(\S(?:.*?\S)?)\*\*\*/m,
      open: ->(_value) { '<strong><em>' },
      close: '</em></strong>',
    },
    {
      pattern: /\*\*(\S(?:.*?\S)?)\*\*/m,
      open: ->(_value) { '<strong>' },
      close: '</strong>',
    },
    {
      pattern: /\*(\S(?:.*?\S)?)\*/m,
      open: ->(_value) { '<em>' },
      close: '</em>',
    },
    {
      pattern: /~~(\S(?:.*?\S)?)~~/m,
      open: ->(_value) { '<del>' },
      close: '</del>',
    },
    {
      pattern: %r{\[color=(#{HEX_COLOR_RE})\](.*?)\[/color\]}im,
      open: ->(value) { %(<span class="md-color" style="color: #{value.downcase}">) },
      close: '</span>',
    },
    {
      pattern: %r{\[bg=(#{HEX_COLOR_RE})\](.*?)\[/bg\]}im,
      open: ->(value) { %(<span class="md-bg" style="background-color: #{value.downcase}">) },
      close: '</span>',
    },
    {
      pattern: %r{\[(left|center|right)\](.*?)\[/\1\]}im,
      open: ->(value) { %(<span class="md-align-#{value.downcase}">) },
      close: '</span>',
    },
    {
      pattern: %r{\[big\](.*?)\[/big\]}im,
      open: ->(_value) { '<span class="md-size-big">' },
      close: '</span>',
    },
  ].freeze

  attr_reader :text, :options

  def initialize(text, options = {})
    @text = text
    @options = options
    @tokens = {}
  end

  def to_s
    return add_quote_fallback('').html_safe if text.blank? # rubocop:disable Rails/OutputSafety

    html = TextFormatter.new(tokenize_custom_tags(text), formatter_options).to_s
    html = restore_custom_tags(html)
    html = Sanitize.fragment(html, Sanitize::Config::MASTODON_STRICT)
    html = add_quote_fallback(html) if options[:quoted_status].present?

    html.html_safe # rubocop:disable Rails/OutputSafety
  rescue ArgumentError
    ''.html_safe
  end

  private

  def tokenize_custom_tags(input)
    CUSTOM_TAGS.reduce(input.dup) do |result, tag|
      previous = nil

      until previous == result
        previous = result
        result = result.gsub(tag[:pattern]) do
          value = Regexp.last_match.length == 3 ? Regexp.last_match(1) : nil
          content = Regexp.last_match(Regexp.last_match.length - 1)
          open_token = store_token(tag[:open].call(value))
          close_token = store_token(tag[:close])

          "#{open_token}#{content}#{close_token}"
        end
      end

      result
    end
  end

  def store_token(html)
    token = "#{TOKEN_PREFIX}#{@tokens.size}_"
    @tokens[token] = html
    token
  end

  def restore_custom_tags(html)
    @tokens.reduce(html) { |result, (token, replacement)| result.gsub(token, replacement) }
  end

  def formatter_options
    options.merge(quoted_status: nil)
  end

  def add_quote_fallback(html)
    return html if options[:quoted_status].nil?

    url = ActivityPub::TagManager.instance.url_for(options[:quoted_status]) || ActivityPub::TagManager.instance.uri_for(options[:quoted_status])
    return html if url.blank? || html.include?(url)

    %(<p class="quote-inline">RE: #{TextFormatter.shortened_link(url)}</p>#{html})
  end
end
