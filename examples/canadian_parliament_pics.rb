require 'screp'

Screp.scrape 'http://www.parl.gc.ca/MembersOfParliament/MainMPsCompleteList.aspx?TimePeriod=Current&Language=E' do

  first 'table#MasterPage_MasterPage_BodyContent_PageContent_Content_ListContent_ListContent_grdCompleteList' do

    # the data we'll be scraping
    log "Representative", "RepresentativeLink", "Constituency", "ConstituencyLink", "Province", "Caucus", "CaucusHomepage"

    # first html table row contains headers, so let's skip it
    each 'tr', (1..-1) do

      rep_data = []
      each 'td' do |index|

        if link = links.first
          # table cells contain either a link
          rep_data += [link.keys.first, link.values.first]
        else
          # or just text (in the case of province/territory column)
          rep_data << text
        end

      end

      log rep_data
    end
  end
end
