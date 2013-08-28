require_relative '../../spec_helper'

class Dummy
  @url = 'http://dummy.com'
end

describe HttpUtilities do
  let(:hu) { Dummy.new.extend(HttpUtilities) }

  describe '#full_href' do
    hu.full_href('/test.html').shoudl == 'http://dummy.com/test.html'
  end


end
