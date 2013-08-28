require 'nokogiri'
require 'open-uri'

module Screp
  module HttpUtilities

    def full_href(relative_href)
      URI.join(@url, encoded_href(relative_href)).to_s
    end

    def encoded_href(href)
      href == URI.decode(href) ? URI.encode(href) : href
    end

    def nbsp
      @nbsp ||= Nokogiri::HTML("&nbsp;").text
    end
  end
end
