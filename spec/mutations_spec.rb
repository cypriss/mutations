require 'spec_helper'

describe 'Mutations' do

  it 'should have a version' do
    assert_kind_of String, Mutations::VERSION
  end

end
