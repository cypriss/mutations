require_relative 'spec_helper'

describe 'Mutations' do
  
  class SimpleCommand < Mutations::Command
    
    required do
      string :name, length: 10
      string :email
    end
    
    optional do
      integer :amount
    end
    
    def execute
      "hi"
    end
  end
  
  
  
  # class SimpleInherited < SimpleCommand
  #   
  #   required do
  #     string :name, length: 10
  #     string :email
  #   end
  #   
  #   optional do
  #     integer :amount
  #   end
  #   
  #   def execute
  #     @filtered_input
  #   end
  # end
  
  it 'should have a version' do
    assert Mutations::VERSION.is_a?(String)
  end
  
end
