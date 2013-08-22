require_relative '../../spec_helper'

class Dummy
end

describe HttpUtilities do
  let(:hu) { Dummy.new.extend(HttpUtilities) }


end
