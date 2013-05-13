require 'spec_helper'
require 'simple_command'

describe 'Mutations - inheritance' do

  class SimpleInherited < SimpleCommand

    required do
      integer :age
    end

    def execute
      inputs
    end
  end

  it 'should filter with inherited command' do
    mutation = SimpleInherited.run(:name => "bob", :email => "jon@jones.com", :age => 10, :amount => 22)
    assert mutation.success?
    assert_equal HashWithIndifferentAccess.new(:name => "bob", :email => "jon@jones.com", :age => 10, :amount => 22), mutation.result
  end

  it 'should filter with original command' do
    mutation = SimpleCommand.run(:name => "bob", :email => "jon@jones.com", :age => 10, :amount => 22)
    assert mutation.success?
    assert_equal HashWithIndifferentAccess.new(:name => "bob", :email => "jon@jones.com", :amount => 22), mutation.result
  end

  it 'shouldnt collide' do
    mutation = SimpleInherited.run(:name => "bob", :email => "jon@jones.com", :age => 10, :amount => 22)
    assert mutation.success?
    assert_equal HashWithIndifferentAccess.new(:name => "bob", :email => "jon@jones.com", :age => 10, :amount => 22), mutation.result

    mutation = SimpleCommand.run(:name => "bob", :email => "jon@jones.com", :age => 10, :amount => 22)
    assert mutation.success?
    assert_equal HashWithIndifferentAccess.new(:name => "bob", :email => "jon@jones.com", :amount => 22), mutation.result
  end

end
