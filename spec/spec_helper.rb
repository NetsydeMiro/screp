require 'simplecov'
require 'fileutils'

def fixture_file(filename)
  File.join('spec/fixtures', filename)
end

def temp_file(filename)
  File.join('tmp', filename)
end

def null_input
  fixture_file 'null_content.html'
end

Dir.mkdir('tmp') if not Dir.exist?('tmp')
FileUtils.rm_rf Dir.glob('tmp/*')

SimpleCov.start do 
  add_filter '/spec/'
end

require_relative '../lib/screp'
require_relative '../lib/screp/text_utilities'
require_relative '../lib/screp/http_utilities'
require_relative '../lib/screp/general_utilities'
