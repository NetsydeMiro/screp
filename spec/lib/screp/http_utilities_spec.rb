require_relative '../../spec_helper'

class Dummy
end

describe Screp::HttpUtilities do
  let(:hu) { Dummy.new.extend(Screp::HttpUtilities) }

end
