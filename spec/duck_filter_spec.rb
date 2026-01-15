require 'spec_helper'

describe "Mutations::DuckFilter" do

  it "allows objects that respond to a single specified method" do
    f = Mutations::DuckFilter.new(:methods => [:length])
    filtered, errors = f.filter("test")
    assert_equal "test", filtered
    assert_nil errors

    filtered, errors = f.filter([1, 2])
    assert_equal [1, 2], filtered
    assert_nil errors
  end

  it "doesn't allow objects that respond to a single specified method" do
    f = Mutations::DuckFilter.new(:methods => [:length])
    filtered, errors = f.filter(true)
    assert_equal true, filtered
    assert_equal :duck, errors

    filtered, errors = f.filter(12)
    assert_equal 12, filtered
    assert_equal :duck, errors
  end

  it "considers nil to be invalid" do
    f = Mutations::DuckFilter.new(:nils => false)
    filtered, errors = f.filter(nil)
    assert_nil filtered
    assert_equal :nils, errors
  end

  it "considers nil to be valid" do
    f = Mutations::DuckFilter.new(:nils => true)
    filtered, errors = f.filter(nil)
    assert_nil filtered
    assert_nil errors
  end

  it "Allows anything if no methods are specified" do
    f = Mutations::DuckFilter.new
    [true, "hi", 1, [1, 2, 3]].each do |v|
      filtered, errors = f.filter(v)
      assert_equal v, filtered
      assert_nil errors
    end
  end
end
