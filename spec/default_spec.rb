require 'spec_helper'
require 'simple_command'

describe 'Mutations - defaults' do

  class DefaultCommand < Mutations::Command
    required do
      string :name, :default => "Bob Jones"
    end

    def execute
      inputs
    end
  end

  it "should have a default if no value is passed" do
    outcome = DefaultCommand.run
    assert_equal true, outcome.success?
    assert_equal({"name" => "Bob Jones"}, outcome.result)
  end

  it "should have the passed value if a value is passed" do
    outcome = DefaultCommand.run(:name => "Fred")
    assert_equal true, outcome.success?
    assert_equal({"name" => "Fred"}, outcome.result)
  end

  it "should be an error if nil is passed on a required field with a default" do
    outcome = DefaultCommand.run(:name => nil)
    assert_equal false, outcome.success?
  end

  class DefaultCommandWithValueMutation < Mutations::Command
    required do
      string :name
      array :names, class: String, default: []
    end

    def execute
      names << name
      inputs
    end
  end

  it "should not leak values between calls of the command" do
    outcome = DefaultCommandWithValueMutation.run(name: "Mary")
    assert_equal true, outcome.success?
    assert_equal({"name" => "Mary", "names" => ["Mary"]}, outcome.result)

    outcome = DefaultCommandWithValueMutation.run(name: "Joe")
    assert_equal true, outcome.success?
    assert_equal({"name" => "Joe", "names" => ["Joe"]}, outcome.result)
  end

end
