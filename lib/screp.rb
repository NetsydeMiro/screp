require_relative "screp/version"
require_relative "screp/text_utilities"
require_relative "screp/http_utilities"
require_relative "screp/screp"

module Screp

    def self.scrape(url, &block)
      scraper = Screp.new(url)

      scraper.instance_eval &block

      scraper.write_log
      scraper.perform_download
    end

end
