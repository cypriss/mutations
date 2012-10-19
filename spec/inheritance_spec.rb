require_relative 'spec_helper'
require 'simple_command'

describe 'Mutations - inheritance' do
  
  class SimpleInherited < SimpleCommand
    
    required do
      integer :age
    end
    
    def execute
      @filtered_input
    end
  end
  
  it 'should filter with merged inputs' do
    mutation = SimpleInherited.run(name: "bob", email: "jon@jones.com", age: 10, amount: 22)
    assert mutation.success?
    
    
  end
  
end
