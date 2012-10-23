require_relative 'spec_helper'
require 'simple_command'

# External API:
# Class.run(...)
# Class.run!(...)

# result API:
# mutation.success?
# mutation.result
# mutation.errors

# internal API:
# def execute; end # what you define
# self.inputs
# self.name # accessors
# self.name = "bob" # setter
# self.name_present? # test to see if a key was passed
# self.add_error(:name, :too_long, "That name is too long")
# self.merge_errors(ErrorHash instance)


describe "Command" do
  
  describe "SimpleCommand" do
    it "should allow valid in put in" do
      mutation = SimpleCommand.run(name: "John", email: "john@gmail.com", amount: 5)

      assert mutation.success?
      assert_equal ({name: "John", email: "john@gmail.com", amount: 5}).stringify_keys, mutation.result
      assert_equal nil, mutation.errors
    end
    
    it "should filter out spurious params" do
      mutation = SimpleCommand.run(name: "John", email: "john@gmail.com", amount: 5, buggers: true)
      
      assert mutation.success?
      assert_equal ({name: "John", email: "john@gmail.com", amount: 5}).stringify_keys, mutation.result
      assert_equal nil, mutation.errors
    end
    
    it "should discover errors in inputs" do
      mutation = SimpleCommand.run(name: "JohnTooLong", email: "john@gmail.com")
      
      assert !mutation.success?
      assert :length, mutation.errors.symbolic[:name]
    end
  end
  
  describe "EigenCommand" do
    class EigenCommand < Mutations::Command
  
      required { string :name }
      optional { string :email }
  
      def execute
        {name: name, email: email}
      end
    end
  
    it "should define getter methods on params" do
      mutation = EigenCommand.run(name: "John", email: "john@gmail.com")
      assert_equal ({name: "John", email: "john@gmail.com"}), mutation.result
    end
  end
  
  describe "MutatatedCommand" do
    class MutatatedCommand < Mutations::Command
  
      required { string :name }
      optional { string :email }
  
      def execute
        self.name, self.email = "bob", "bob@jones.com"
        {name: inputs[:name], email: inputs[:email]}
      end
    end
  
    it "should define setter methods on params" do
      mutation = MutatatedCommand.run(name: "John", email: "john@gmail.com")
      assert_equal ({name: "bob", email: "bob@jones.com"}), mutation.result
    end
  end
end
