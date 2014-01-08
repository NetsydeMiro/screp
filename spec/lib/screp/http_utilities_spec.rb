require_relative '../../spec_helper'

class Dummy
  def url
    'http://dummy.com'
  end
end

describe Screp::HttpUtilities do
  let(:hu) { Dummy.new.extend(Screp::HttpUtilities) }

  describe '#encoded_href' do
    it "does nothing to valid href" do
      hu.encoded_href('http://example.com').should == 'http://example.com'
    end

    it "encodes href that has invalid chars" do
      hu.encoded_href('http://example.com/space here.html').should == 'http://example.com/space%20here.html'
    end
  end

  describe '#full_href' do
    it "merges relative path with server base url" do 
      hu.full_href('/test.html').should == 'http://dummy.com/test.html'
    end
  end

  describe '#nbsp' do
    it "should find the html space in nokogiri content" do
      noko_nbsp = Nokogiri::HTML(open('spec/fixtures/nbsp.html'))
      hu.nbsp.should == noko_nbsp.text
    end
  end

end

