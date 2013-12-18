require 'screp'

puts "test1"

Screp.scrape 'http://www.parl.gc.ca/MembersOfParliament/MainMPsCompleteList.aspx?TimePeriod=Current&Language=E' do

  puts "test2"

  first 'td#MasterPage_MasterPage_BodyContent_PageContent_Content_ListContent_ListContent_grdCompleteList' do

    puts "test3"

    # the data we'll be scraping
    log "Representative", "Homepage", "Constituency", "Homepage", "Province/Territory", "Caucus", "Homepage"

    puts "test4"

    # first html table row contains headers, so let's skip it
    each 'tr', (1..-1) do
      
      puts "test5"

      #row_data = []
      each 'td' do |index|

        puts "test6"

        puts text

      end

      #log row_data
    end
  end
end
