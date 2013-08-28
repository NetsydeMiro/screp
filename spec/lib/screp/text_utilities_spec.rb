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

  describe '#filename_scrub' do 

    it 'should replace non alphanumerics' do
      tu.filename_scrub('!safe/file$name@here]').should == '_safe_file_name_here_'
    end
  end

  describe '#typo' do

    it 'should correct text with single error' do 
      misspelled = 'misspelled wurddd here'
      tu.typo(misspelled, 'wurddd' => 'word')
      misspelled.should == 'misspelled word here'
    end

    it 'should correct text with multiple errors' do 
      misspelled = 'misspelld wurdddz hear'
      tu.typo(misspelled, 'lld' => 'lled', 'wurdddz' => 'words', 'hear' => 'here')
      misspelled.should == 'misspelled words here'
    end

    it 'should correct an enumerable collection of text' do 
      misspelled = %w{wroang incorrekt badd}
      tu.typo(misspelled, 'wroang' => 'wrong', 'incorrekt' => 'incorrect', 'badd' => 'bad' )
      misspelled.should == %w{wrong incorrect bad}
    end
  end
end
