require 'spec_helper'

describe 'Mutations' do

  it 'should have a version' do
    assert Mutations::VERSION.is_a?(String)
  end

end
