require_relative '../../spec_helper'

describe Screp::Screp do

  describe "Parsing" do 

    let :table do 
      screp = Screp::Screp.new(silent: true)
      screp.scrape('spec/fixtures/table.html')
      screp
    end

    describe "#method_missing" do 
      it "raises error if it or nokogiri doesn't handle the method" do
        expect {
          table.dummy_method
        }.to raise_error NoMethodError
      end
    end

    describe "#count" do 
      it "finds the correct count" do 
        table.count('tr').should == 3
      end
    end

    describe "#first" do 
      it "finds the correct node" do 
        table.first('td') do 
          content.should == 'row1 col1'
        end
      end

      it "doesn't require a block" do 
        table.first('td').content.should == 'row1 col1'
      end
    end

    describe "#last" do 
      it "finds the correct node" do 
        table.last 'td' do 
          content.should == 'row3 col2'
        end
      end
      it "doesn't require a block" do 
        table.last('td').content.should == 'row3 col2'
      end
    end

    describe "#each" do 

      it "cycles through each node in order" do
        expected_content = 
          ['row1 col1row1 col2', 
            'row2 col1row2 col2', 
            'row3 col1row3 col2']

        actual_content = []

        table.each 'tr' do 
          actual_content << content.strip
        end

        actual_content.should == expected_content
      end

      it "passes correct indices" do 
        expected_indices = [0,1,2]
        actual_indices = []

        table.each 'tr' do |row_index|
          actual_indices << row_index
        end

        actual_indices.should == expected_indices

      end

      it "can process a specified node" do 
        expected_content = 
          ['row2 col1row2 col2']

        actual_content = []

        table.each 'tr', 1 do 
          actual_content << content.strip
        end

        actual_content.should == expected_content
      end

      it "can process a specified range" do 

        expected_content = 
          ['row1 col1row1 col2', 
            'row2 col1row2 col2']
        actual_content = []

        table.each 'tr', 0..1 do 
          actual_content << content.strip
        end

        actual_content.should == expected_content
      end

      it "can process an end range" do 

        expected_content = 
          ['row2 col1row2 col2', 
            'row3 col1row3 col2']
        actual_content = []

        table.each 'tr', 1..-1 do 
          actual_content << content.strip
        end

        actual_content.should == expected_content
      end

      it "is able to nest" do

        expected_content = 
          ['row2 col1', 'row2 col2']

        actual_content = []

        table.each 'tr', 1 do 
          each 'td' do
            actual_content << content.strip
          end
        end

        actual_content.should == expected_content
      end
    end

  end

end
