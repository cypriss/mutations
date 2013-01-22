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
  
end
