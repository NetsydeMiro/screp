require_relative '../../spec_helper'

describe Screp::Screp do

  def csv_output
    temp_file 'test.csv'
  end

  describe "Logging Functionality" do 

    after :each do
      FileUtils.rm_rf Dir.glob('tmp/*')
    end

    it "doesn't log if no info logged" do 
      screp = Screp::Screp.new(silent: true)
      screp.scrape('spec/fixtures/null_content.html') do
        write_log
      end

      File.exists?('spec_fixtures_null_content_html.csv').should be_false
    end

    it "ouputs correct default filename" do 
      screp = Screp::Screp.new(silent: true)

      screp.scrape('spec/fixtures/null_content.html') do
        log "Test"
      end

      screp.write_log

      File.exists?('spec_fixtures_null_content_html.csv').should be_true

      File.delete 'spec_fixtures_null_content_html.csv'
    end

    it "ouputs correct filename" do 
      screp = Screp::Screp.new(silent: true)
      screp.scrape('spec/fixtures/null_content.html') do
        init_log(filename: temp_file('differentfilename.csv'))
        log "Test"
        write_log
      end

      File.exists?(temp_file 'differentfilename.csv').should be_true
    end


    it "writes headers if specified" do 
      screp = Screp::Screp.new
      screp.init_log(filename: csv_output, 
                     headers: ['header1', 'header2', 'header3'])

      screp.write_log

      File.readlines(csv_output).first.strip.should == 'header1,header2,header3'
    end

    it "writes data correctly when provided as arguments" do 
      screp = Screp::Screp.new
      screp.init_log(filename: csv_output)

      screp.log 'test1', 'test2'
      screp.log 'test3', 'test4'

      screp.write_log

      lines = File.readlines(csv_output)

      lines.first.strip.should == 'test1,test2'
      lines.last.strip.should == 'test3,test4'
    end

    it "writes data correctly when provided as array" do 
      screp = Screp::Screp.new
      screp.init_log(filename: csv_output)

      screp.log ['test1', 'test2']
      screp.log ['test3', 'test4']

      screp.write_log

      lines = File.readlines(csv_output)

      lines.first.strip.should == 'test1,test2'
      lines.last.strip.should == 'test3,test4'
    end

  end
end

