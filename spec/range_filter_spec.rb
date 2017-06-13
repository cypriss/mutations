require 'spec_helper'

describe "Mutations::RangerFilter" do

  it "allows ranges" do
    f = Mutations::RangeFilter.new
    filtered, errors = f.filter(1..3)
    assert_equal 1..3, filtered
    assert_equal nil, errors
  end

  it "allows integer ranges if type option is filled with integer" do
    f = Mutations::RangeFilter.new(type: Integer)
    filtered, errors = f.filter(1..3)
    assert_equal 1..3, filtered
    assert_equal nil, errors
  end

  it "disallows non-integer ranges if type option is filled with integer" do
    f = Mutations::RangeFilter.new(type: Integer)
    filtered, errors = f.filter('A'..'C')
    assert_equal 'A'..'C', filtered
    assert_equal :type, errors
  end

  it "considers nil to be invalid" do
    f = Mutations::RangeFilter.new(:nils => false)
    filtered, errors = f.filter(nil)
    assert_equal nil, filtered
    assert_equal :nils, errors
  end

  it "considers nil to be valid" do
    f = Mutations::RangeFilter.new(:nils => true)
    filtered, errors = f.filter(nil)
    assert_equal nil, filtered
    assert_equal nil, errors
  end

  it "considers low numbers invalid" do
    f = Mutations::RangeFilter.new(:min => 10)
    filtered, errors = f.filter(1..3)
    assert_equal 1..3, filtered
    assert_equal :min, errors
  end

  it "considers low numbers valid" do
    f = Mutations::RangeFilter.new(:min => 10)
    filtered, errors = f.filter(31..40)
    assert_equal 31..40, filtered
    assert_equal nil, errors
  end

  it "considers high numbers invalid" do
    f = Mutations::RangeFilter.new(:max => 10)
    filtered, errors = f.filter(31..40)
    assert_equal 31..40, filtered
    assert_equal :max, errors
  end

  it "considers high numbers vaild" do
    f = Mutations::RangeFilter.new(:max => 10)
    filtered, errors = f.filter(1..3)
    assert_equal 1..3, filtered
    assert_equal nil, errors
  end
end
