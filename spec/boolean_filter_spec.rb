require 'spec_helper'

describe "Mutations::BooleanFilter" do

  it "allows booleans" do
    f = Mutations::BooleanFilter.new
    filtered, errors = f.filter(true)
    assert_equal true, filtered
    assert_nil errors

    filtered, errors = f.filter(false)
    assert_equal false, filtered
    assert_nil errors
  end

  it "considers non-booleans to be invalid" do
    f = Mutations::BooleanFilter.new
    [[true], {:a => "1"}, Object.new].each do |thing|
      _filtered, errors = f.filter(thing)
      assert_equal :boolean, errors
    end
  end

  it "considers nil to be invalid" do
    f = Mutations::BooleanFilter.new(:nils => false)
    filtered, errors = f.filter(nil)
    assert_nil filtered
    assert_equal :nils, errors
  end

  it "considers nil to be valid" do
    f = Mutations::BooleanFilter.new(:nils => true)
    filtered, errors = f.filter(nil)
    assert_nil filtered
    assert_nil errors
  end

  it "considers certain strings to be valid booleans" do
    f = Mutations::BooleanFilter.new
    [["true", true], ["TRUE", true], ["TrUe", true], ["1", true], ["false", false], ["FALSE", false], ["FalSe", false], ["0", false], [0, false], [1, true]].each do |(str, v)|
      filtered, errors = f.filter(str)
      assert_equal v, filtered
      assert_nil errors
    end
  end
  
  it "considers empty strings to be empty" do
    f = Mutations::BooleanFilter.new
    _filtered, errors = f.filter("")
    assert_equal :empty, errors
  end

  it "considers other string to be invalid" do
    f = Mutations::BooleanFilter.new
    ["truely", "2"].each do |str|
      filtered, errors = f.filter(str)
      assert_equal str, filtered
      assert_equal :boolean, errors
    end
  end
end
