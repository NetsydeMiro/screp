require_relative '../../spec_helper'

describe Screp::Screp do


  describe "Downloading Functionality" do 

    let(:out){ StringIO.new }
    let(:err){ StringIO.new }

    after :each do
      FileUtils.rm_rf Dir.glob('tmp/*')
    end

    it "creates correct default directory" do 
      screp = Screp::Screp.new('spec/fixtures/null_content.html')
      screp.init_download

      screp.perform_download out, err

      Dir.exists?('spec_fixtures_null_content_html').should be_true

      FileUtils.rm_rf 'spec_fixtures_null_content_html'
    end

    it "creates correct specified directory" do 
      screp = Screp::Screp.new('spec/fixtures/null_content.html')
      screp.init_download(directory: temp_file('download_directory'))

      screp.perform_download out, err

      Dir.exists?(temp_file 'download_directory').should be_true
    end

    it "downloads specified file correctly" do 
      screp = Screp::Screp.new('spec/fixtures/null_content.html')
      screp.init_download(directory: temp_file('download_directory'))

      screp.download fixture_file('download.txt') => 'new_name.txt' 

      screp.perform_download out, err

      File.exists?(temp_file 'download_directory/new_name.txt').should be_true
      File.readlines(temp_file 'download_directory/new_name.txt').should == File.readlines(fixture_file 'download.txt')
    end

    it "downloads default file correctly" do 
      screp = Screp::Screp.new('spec/fixtures/null_content.html')
      screp.init_download(directory: temp_file('download_directory'))

      screp.download fixture_file('download.txt')

      screp.perform_download out, err

      File.exists?(temp_file 'download_directory/download.txt').should be_true
      File.readlines(temp_file 'download_directory/download.txt').should == File.readlines(fixture_file 'download.txt')
    end

    describe "overwriting functionality" do 

      before :each do 
        Dir.mkdir(temp_file('download_directory'))
        File.open(temp_file('download_directory/download.txt'), 'w') do |f|
          f.write "Pre-existing file"
        end
      end

      it "doesn't overwrite previously downloaded files by default" do 
        screp = Screp::Screp.new('spec/fixtures/null_content.html')
        screp.init_download(directory: temp_file('download_directory'))

        screp.download fixture_file('download.txt')

        screp.perform_download out, err

        File.exists?(temp_file 'download_directory/download.txt').should be_true
        File.readlines(temp_file 'download_directory/download.txt').should == ["Pre-existing file"]
      end

      it "overwrites previously downloaded files when specified" do 
        screp = Screp::Screp.new('spec/fixtures/null_content.html')
        screp.init_download(directory: temp_file('download_directory'), overwrite: true)

        screp.download fixture_file('download.txt')

        screp.perform_download out, err

        File.exists?(temp_file 'download_directory/download.txt').should be_true
        File.readlines(temp_file 'download_directory/download.txt').should == File.readlines(fixture_file 'download.txt')
      end
    end

  end
end
