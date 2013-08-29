require_relative '../../spec_helper'

describe Screp::Screp do

  def fixture_file(filename)
    File.join('spec/fixtures', filename)
  end

  def temp_file(filename)
    File.join('tmp', filename)
  end

  def null_input
    fixture_file 'null_content.html'
  end

  def csv_output
    temp_file 'test.csv'
  end

  describe "CSV Logging" do 

    before :all do 
      Dir.mkdir('tmp') if not Dir.exist?('tmp')
      FileUtils.rm_rf Dir.glob('tmp/*')
    end

    after :each do
      FileUtils.rm_rf Dir.glob('tmp/*')
    end

    it "ouputs correct default filename" do 
      screp = Screp::Screp.new('spec/fixtures/null_content.html')
      screp.init_csv

      screp.output_csv

      File.exists?('spec_fixtures_null_content_html.csv').should be_true

      File.delete 'spec_fixtures_null_content_html.csv'
    end

    it "ouputs correct filename" do 
      screp = Screp::Screp.new(null_input)
      screp.init_csv(filename: temp_file('differentfilename.csv'))
      screp.output_csv

      File.exists?(temp_file 'differentfilename.csv').should be_true
    end


    it "writes headers if specified" do 
      screp = Screp::Screp.new(null_input)
      screp.init_csv(filename: csv_output, 
                     headers: ['header1', 'header2', 'header3'])

      screp.output_csv

      File.readlines(csv_output).first.strip.should == 'header1,header2,header3'
    end

    it "writes data correctly" do 
      screp = Screp::Screp.new(null_input)
      screp.init_csv(filename: csv_output)

      screp.csv 'test1', 'test2'
      screp.csv 'test3', 'test4'

      screp.output_csv

      lines = File.readlines(csv_output)
      
      lines.first.strip.should == 'test1,test2'
      lines.last.strip.should == 'test3,test4'
    end

  end
end

