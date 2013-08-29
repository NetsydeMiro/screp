require_relative '../../spec_helper'

describe Screp::Screp do


  describe "Downloading Functionality" do 

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
      screp.init_download(directory: temp_file('download_directory'))
      screp.perform_download

      Dir.exists?(temp_file 'download_directory').should be_true
    end

    it "downloads specified file correctly" do 
      screp = Screp::Screp.new('spec/fixtures/null_content.html')
      screp.init_download(directory: temp_file('download_directory'))

      screp.download fixture_file('download.txt') => 'new_name.txt' 
      screp.perform_download

      File.exists?(temp_file 'download_directory/new_name.txt').should be_true
      File.readlines(temp_file 'download_directory/new_name.txt').should == File.readlines(fixture_file 'download.txt')
    end

  end
end

