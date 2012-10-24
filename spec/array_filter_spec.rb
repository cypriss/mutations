require_relative 'spec_helper'

describe "Mutations::ArrayFilter" do
  
  it "allows arrays" do
    f = Mutations::ArrayFilter.new(:arr)
    filtered, errors = f.filter([1])
    assert_equal [1], filtered
    assert_equal nil, errors
  end
  
  it "considers non-arrays to be invalid" do
    f = Mutations::ArrayFilter.new(:arr)
    ['hi', true, 1, {a: "1"}, Object.new].each do |thing|
      filtered, errors = f.filter(thing)
      assert_equal :array, errors
    end
  end
  
  it "considers nil to be invalid" do
    f = Mutations::ArrayFilter.new(:arr, nils: false)
    filtered, errors = f.filter(nil)
    assert_equal nil, filtered
    assert_equal :nils, errors
  end
  
  it "considers nil to be valid" do
    f = Mutations::ArrayFilter.new(:arr, nils: true)
    filtered, errors = f.filter(nil)
    filtered, errors = f.filter(nil)
    assert_equal nil, errors
  end
  
  it "lets you use a block to supply an element filter" do
    f = Mutations::ArrayFilter.new(:arr) { string }
    
    filtered, errors = f.filter(["hi", {stuff: "ok"}])
    assert_nil errors[0]
    assert_equal :string, errors[1].symbolic
  end
  
end