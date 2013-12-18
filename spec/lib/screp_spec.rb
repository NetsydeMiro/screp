require_relative '../spec_helper'

describe Screp do

  describe "no errors" do
    Screp.scrape("http://www.google.com") do 
    end
  end

end
