require_relative '../../spec_helper'

class Dummy
end

describe TextUtilities do

  let(:tu) { Dummy.new.extend(TextUtilities) }

  describe '#titlize' do

    it 'should titlize a word' do
      tu.titlize('capital').should == 'Capital'
    end

    it 'should titlize multiple words' do
      tu.titlize('capital city').should == 'Capital City'
    end

    it 'should strip leading/trailing white space' do
      tu.titlize(" capital  \t").should == 'Capital'
    end

    it 'should compress multiple dividing spaces into one' do
      tu.titlize("capital    many     spaces").should == 'Capital Many Spaces'
    end

  end
end
