require 'screp'

Screp.scrape 'http://www.parl.gc.ca/MembersOfParliament/MainMPsCompleteList.aspx?TimePeriod=Current&Language=E' do

  init_download directory: 'images', overwrite: false

  first 'table#MasterPage_MasterPage_BodyContent_PageContent_Content_ListContent_ListContent_grdCompleteList' do

    # the data we'll be scraping
    log "RepId", "Representative", "RepresentativeLink", "Constituency", "ConstituencyLink", "Province", "Caucus", "CaucusHomepage", "ImageLink", "ImageName"

    # first html table row contains headers, so let's skip it
    each 'tr', (1..-1) do

      # we want to build out our data
      rep_data = []

      each 'td' do |index|

        # add the data that's readily available
        if link = links.first
          # table cells contain either a link
          rep_data += [link.keys.first, link.values.first]
        else
          # or just text (in the case of province/territory column)
          rep_data << text
        end

      end

      image_link = ''

      # go to rep's page to scrape their image
      scrape full_href(rep_data[1]) do 

        first 'img#MasterPage_MasterPage_BodyContent_PageContent_Content_TombstoneContent_TombstoneContent_ucHeaderMP_imgPhoto' do

          image_link = full_href attribute('src').value

          download image_link

        end

      end

      # add image link to end of row
      rep_data << image_link

      # add data that we interpolate from existing data
      # add image name to end of row
      rep_data << image_link.split('/').last
      # insert rep Id at beginning of row
      rep_data.unshift rep_data[1].scan(/\d+/).first

      log rep_data
    end
  end
end
