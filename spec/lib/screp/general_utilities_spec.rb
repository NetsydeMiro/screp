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

end
