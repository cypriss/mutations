require 'spec_helper'
require 'simple_command'

describe 'Mutations - defaults' do

  class DefaultCommand < Mutations::Command
    required do
      string :name, :default => "Bob Jones"
      string :dynamic_name, :default => -> { "Bob Dynamicpants" }
    end

    def execute
      inputs
    end
  end

  it "should have a default if no value is passed" do
    outcome = DefaultCommand.run
    assert_equal true, outcome.success?
    assert_equal({"name" => "Bob Jones", "dynamic_name" => "Bob Dynamicpants"}, outcome.result)
  end

  it "should have the passed value if a value is passed" do
    outcome = DefaultCommand.run(:name => "Fred", :dynamic_name => "Fred")
    assert_equal true, outcome.success?
    assert_equal({"name" => "Fred", "dynamic_name" => "Fred"}, outcome.result)
  end

  it "should be an error if nil is passed on a required field with a default" do
    outcome = DefaultCommand.run(:name => nil)
    assert_equal false, outcome.success?
  end

end
