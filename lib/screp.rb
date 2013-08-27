require_relative "screp/version"
require_relative "screp/text_utilities"
require_relative "screp/http_utilities"
require_relative "screp/screp"

module Screp

    def self.scrape(url, &block)
      scraper = Screp::Screp.new(url)

      scraper.instance_eval &block

      scraper.output_csv unless @csv.length == 0
      scraper.perform_download unless @download.length == 0 
    end

end
