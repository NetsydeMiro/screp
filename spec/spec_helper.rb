require 'simplecov'

SimpleCov.start

require_relative '../lib/screp'
require_relative '../lib/screp/text_utilities'
require_relative '../lib/screp/http_utilities'
require_relative '../lib/screp/general_utilities'

def clear_files(dir, glob)
  Dir.glob(File.join(dir, glob)).each {|f| File.delete(f)}
end
