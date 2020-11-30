require 'spec_helper'

describe 'Chickens' do

  it 'should have a version' do
    assert_kind_of String, Chickens::VERSION
  end

end
