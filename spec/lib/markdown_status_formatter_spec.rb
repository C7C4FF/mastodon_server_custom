# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MarkdownStatusFormatter do
  it 'formats the allowlisted syntax' do
    fragment = Nokogiri::HTML5.fragment(described_class.new(<<~TEXT).to_s)
      **bold**
      *italic*
      ***both***
      ~~strike~~
      [color=#ff6699]color[/color]
      [bg=#fff2a8]background[/bg]
      [left]left[/left]
      [center]center[/center]
      [right]right[/right]
      [big]big[/big]
    TEXT

    expect(fragment.css('strong').map(&:text)).to eq(%w(bold both))
    expect(fragment.css('em').map(&:text)).to eq(%w(italic both))
    expect(fragment.css('del').map(&:text)).to eq(%w(strike))
    expect(fragment.at_css('.md-color')['style']).to eq('color: #ff6699')
    expect(fragment.at_css('.md-bg')['style']).to eq('background-color: #fff2a8')
    expect(fragment.css('[class^="md-align-"]').pluck('class')).to eq(%w(md-align-left md-align-center md-align-right))
    expect(fragment.at_css('.md-size-big').text).to eq('big')
  end

  it 'leaves other Redcarpet syntax unformatted' do
    fragment = Nokogiri::HTML5.fragment(described_class.new(<<~TEXT).to_s)
      # heading
      > quote
      - list
      `code`
      __underscores__
      [link](https://example.com)
      <u>html</u>
      #hashtag
    TEXT

    expect(fragment.css('blockquote, ul, ol, code, u')).to be_empty
    expect(fragment.css('strong, em, del')).to be_empty
    expect(fragment.text).to include('# heading', '> quote', '- list', '`code`', '__underscores__', '[link](https://example.com)', '<u>html</u>')
    expect(fragment.at_css('a.hashtag').text).to eq('#hashtag')
  end
end
