require_relative '../../spec_helper'

class Dummy
end

describe Screp::GeneralUtilities do
  let(:gu) { Dummy.new.extend(Screp::GeneralUtilities) }

  describe '#check_options' do 

    it "does nothing if option valid" do 
      gu.check_options({test1: 1, test2: 2}, :test1, :test2, :test3) 
    end

    it "raises an exception if invalid option detected" do
      expect {
        gu.check_options({test3: 1}, :test1, :test2)
      }.to raise_error ArgumentError
    end

    it "has correct error text" do
      begin
        gu.check_options({test3: 1}, :test1, :test2)
      rescue ArgumentError => err
        err.to_s.should == "Option 'test3' not supported"
      end
    end

  end

  describe "#format_download" do 

    it "returns default hash if specified as string" do 
      dl = gu.format_download('http://dummy.com/test/file.html')

      dl.should == {'http://dummy.com/test/file.html' => 'file.html'}
    end

    it "returns hash if specified as hash" do
      hash = {'http://dummy.com/test/file.html' => 'different_name.html'}

      gu.format_download(hash).should == hash
    end

    it "throws exception otherwise" do
      expect {
        gu.format_download(1)
      }.to raise_error ArgumentError
    end

    it "has correct error text" do
      begin
        gu.format_download(999)
      rescue ArgumentError => err
        err.to_s.should == "Download must be specified as either a String or Hash"
      end
    end
  end

end
