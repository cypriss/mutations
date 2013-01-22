require_relative 'spec_helper'

describe "Mutations::HashFilter" do

  it "allows valid hashes" do
    hf = Mutations::HashFilter.new do
      string :foo
    end
    filtered, errors = hf.filter(foo: "bar")
    assert_equal ({"foo" => "bar"}), filtered
    assert_equal nil, errors
  end
  
  it 'disallows non-hashes' do
    hf = Mutations::HashFilter.new do
      string :foo
    end
    filtered, errors = hf.filter("bar")
    assert_equal :hash, errors
  end
  
  it 'allows general hashes' do
    hf = Mutations::HashFilter.new(key_class: String, value_class: Symbol)
    filtered, errors = hf.filter("f1" => :v1, "f2" => :v2)
    assert_equal ({"f1" => :v1, "f2" => :v2}), filtered
    assert_equal nil, errors
  end
  
  it 'doesnt allows invalid general hashes (wrong value type)' do
    hf = Mutations::HashFilter.new(key_class: String, value_class: Symbol)
    filtered, errors = hf.filter("f1" => "v1", "f2" => :v2)
    assert_equal ({"f1" => :value_class}), errors.symbolic
  end
  
  it 'doesnt allows invalid general hashes (wrong key type)' do
    hf = Mutations::HashFilter.new(key_class: Fixnum, value_class: Symbol)
    filtered, errors = hf.filter("f1" => :v1)
    assert_equal ({"f1" => :key_class}), errors.symbolic
  end
  
end
