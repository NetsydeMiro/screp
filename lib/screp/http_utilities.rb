require 'nokogiri'
require 'open-uri'

module Screp
  module HttpUtilities

    def full_href(relative_href)
      URI.join(url, encoded_href(relative_href)).to_s
    end

    def encoded_href(href)
      href == URI.decode(href) ? URI.encode(href) : href
    end

    def nbsp
      @nbsp ||= Nokogiri::HTML("&nbsp;").text
    end

    def links(node = selected)
      result = []

      if node.name == 'a'
        result << {node.text => node.attributes['href'].value}
      end

      node.children.reduce(result){|acc, child| result + links(child)}
    end

  end
end
