require_relative '../../spec_helper'

describe Screp::Screp do

  describe "Output Functionality" do 

    let(:mock_out){ StringIO.new }
    let(:mock_err){ StringIO.new }

    after :each do
      FileUtils.rm_rf Dir.glob('tmp/*')
    end

    def create_fixtures(number = 3)
      names = Array.new(number, 'test').each_with_index.map{|base, i| fixture_file(base + i.to_s + '.txt')}

      names.each do |name|
        File.open(name, 'w') do |f|
          f.print "This is file #{name}"
        end
      end

      names
    end

    it "updates progress" do 
      names = create_fixtures(5)

      screp = Screp::Screp.new(out: mock_out, err: mock_err)
      screp.init_download(directory: temp_file('download_directory'))

      names.each do |name|
        screp.download name
      end

      mock_err.should_receive(:print).exactly(5).times

      screp.perform_download

      names.each {|n| File.delete n}
    end

  end
end
