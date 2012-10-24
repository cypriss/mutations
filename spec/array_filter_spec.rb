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
  
  it "lets you array-ize everything" do
    f = Mutations::ArrayFilter.new(:arr, arrayize: true) { string }
    
    filtered, errors = f.filter("foo")
    assert_equal ["foo"], filtered
    assert_nil errors
  end
  
  it "lets you array-ize an empty string" do
    f = Mutations::ArrayFilter.new(:arr, arrayize: true) { string }
    
    filtered, errors = f.filter("")
    assert_equal [], filtered
    assert_nil errors
  end
  
  # test strings in arrays
  # test integers in arrays
  # test booleans in arrays
  # test models in arrays
  # test hashes in arrays
  # test arrays in arrays
  
  it "lets you pass arrays of arrays" do
    f = Mutations::ArrayFilter.new(:arr) do
      array do
        string
      end
    end
    
    filtered, errors = f.filter([["h", "e"], ["l"], [], ["lo"]])
    assert_equal filtered, [["h", "e"], ["l"], [], ["lo"]]
    assert_equal nil, errors
  end
  
  it "handles errors for arrays of arrays" do
    f = Mutations::ArrayFilter.new(:arr) do
      array do
        string
      end
    end
    
    filtered, errors = f.filter([["h", "e", {}], ["l"], [], [""]])
    assert_equal [[nil, nil, :string], nil, nil, [:empty]], errors.symbolic
    assert_equal [[nil, nil, "Array[2] isn't a string"], nil, nil, ["Array[0] can't be blank"]], errors.message
    assert_equal ["Array[2] isn't a string", "Array[0] can't be blank"], errors.message_list
  end
  
end