require 'spec_helper'

describe "Mutations::FloatFilter" do

  it "allows floats" do
    f = Mutations::FloatFilter.new
    filtered, errors = f.filter(3.1415926)
    assert_equal 3.1415926, filtered
    assert_equal nil, errors
  end

  it "allows strings that start with a digit" do
    f = Mutations::FloatFilter.new
    filtered, errors = f.filter("3")
    assert_equal 3.0, filtered
    assert_equal nil, errors
  end

  it "allows string representation of float" do
    f = Mutations::FloatFilter.new
    filtered, errors = f.filter("3.14")
    assert_equal 3.14, filtered
    assert_equal nil, errors
  end

  it "allows string representation of float without a number before dot" do
    f = Mutations::FloatFilter.new
    filtered, errors = f.filter(".14")
    assert_equal 0.14, filtered
    assert_equal nil, errors
  end

  it "allows negative strings" do
    f = Mutations::FloatFilter.new
    filtered, errors = f.filter("-.14")
    assert_equal(-0.14, filtered)
    assert_equal nil, errors
  end

  it "allows strings with a positive sign" do
    f = Mutations::FloatFilter.new
    filtered, errors = f.filter("+.14")
    assert_equal 0.14, filtered
    assert_equal nil, errors
  end

  it "doesnt't allow other strings, nor does it allow random objects or symbols" do
    f = Mutations::FloatFilter.new
    ["zero","a1", {}, [], Object.new, :d].each do |thing|
      _filtered, errors = f.filter(thing)
      assert_equal :float, errors
    end
  end

  it "considers nil to be invalid" do
    f = Mutations::FloatFilter.new(:nils => false)
    filtered, errors = f.filter(nil)
    assert_equal nil, filtered
    assert_equal :nils, errors
  end

  it "considers nil to be valid" do
    f = Mutations::FloatFilter.new(:nils => true)
    filtered, errors = f.filter(nil)
    assert_equal nil, filtered
    assert_equal nil, errors
  end
  
  it "considers empty strings to be empty" do
    f = Mutations::FloatFilter.new
    _filtered, errors = f.filter("")
    assert_equal :empty, errors
  end

  it "considers low numbers invalid" do
    f = Mutations::FloatFilter.new(:min => 10)
    filtered, errors = f.filter(3)
    assert_equal 3, filtered
    assert_equal :min, errors
  end

  it "considers low numbers valid" do
    f = Mutations::FloatFilter.new(:min => 10)
    filtered, errors = f.filter(31)
    assert_equal 31, filtered
    assert_equal nil, errors
  end

  it "considers high numbers invalid" do
    f = Mutations::FloatFilter.new(:max => 10)
    filtered, errors = f.filter(31)
    assert_equal 31, filtered
    assert_equal :max, errors
  end

  it "considers high numbers vaild" do
    f = Mutations::FloatFilter.new(:max => 10)
    filtered, errors = f.filter(3)
    assert_equal 3, filtered
    assert_equal nil, errors
  end

end
