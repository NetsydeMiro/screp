require_relative '../../spec_helper'

describe Screp::Screp do

  def clear_csv_files
      Dir.glob('*.csv').each {|f| File.delete(f)}
  end

  describe "CSV Logging" do 

    before :all do 
      Dir.mkdir('spec/fixtures/temp')
      Dir.chdir('spec/fixtures/temp')
    end

    after :each do
      require 'pry'; binding.pry
      FileUtils.rm_rf Dir.glob('./*')
    end

    after :all do 
      require 'pry'; binding.pry
      Dir.chdir('../../..')
      FileUtils.rm_rf 'spec/fixtures/temp'
    end

    it "ouputs correct filename" do 
      screp = Screp::Screp.new('../csv_test_null_content.html')
      screp.init_csv(filename: 'differentfilename.csv')

      screp.output_csv

      File.exists?('differentfilename.csv').should be_true
    end

    it "ouputs correct default filename" do 
      screp = Screp::Screp.new('../csv_test_null_content.html')
      screp.init_csv

      screp.output_csv

      File.exists?('___csv_test_null_content_html.csv').should be_true
    end

    it "writes headers if specified" do 
      screp = Screp::Screp.new('../csv_test_null_content.html')
      screp.init_csv(headers: ['header1', 'header2', 'header3'])

      screp.output_csv

      File.readlines('___csv_test_null_content_html.csv').first.strip.should == 'header1,header2,header3'
    end

    it "writes data correctly" do 
      screp = Screp::Screp.new('../csv_test_null_content.html')

      screp.csv 'test1', 'test2'
      screp.csv 'test3', 'test4'

      screp.output_csv

      lines = File.readlines('___csv_test_null_content_html.csv')
      
      lines.first.strip.should == 'test1,test2'
      lines.last.strip.should == 'test3,test4'
    end

  end
end

