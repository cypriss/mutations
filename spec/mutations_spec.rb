require 'backports/1.9.1/kernel/require_relative'
require_relative 'spec_helper'

describe 'Mutations' do

  it 'should have a version' do
    assert Mutations::VERSION.is_a?(String)
  end

end
