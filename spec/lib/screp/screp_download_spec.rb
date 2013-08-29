require_relative '../../spec_helper'

describe Screp::Screp do

  def csv_output
    temp_file 'test.csv'
  end

  describe "Downloading" do 

    before :all do 
    end

    after :each do
      FileUtils.rm_rf Dir.glob('tmp/*')
    end

    it "creates correct default directory" do 
      screp = Screp::Screp.new('spec/fixtures/null_content.html')
      screp.init_download
      screp.perform_download

      Dir.exists?('spec_fixtures_null_content_html').should be_true

      FileUtils.rm_rf 'spec_fixtures_null_content_html'
    end

    it "creates correct specified directory" do 
      screp = Screp::Screp.new('spec/fixtures/null_content.html')
      screp.init_download(directory: temp_file('new_directory'))
      screp.perform_download

      Dir.exists?(temp_file 'new_directory').should be_true
    end

  end
end

